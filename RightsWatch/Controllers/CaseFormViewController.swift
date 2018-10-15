//
//  CaseFormViewController.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 6/29/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//
//  Controller for case entry form

import UIKit
import CoreData // API for interacting with database
import Siesta // Simplifies web requests
import SwiftyJSON // Handles JSON data

enum SaveError: Error {
    case badCite
    case notFound
}

// MARK: Controller for case form view
class CaseFormViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLDelegate {

    // MARK: Variables
    weak var table: MasterViewController?
    var observer: CLObserver?
    var usPage: Int?
    var usVol: Int?
    var sctPage: Int?
    var sctVol: Int?
    var usReporter: Bool = true
    var currentCitation: Citation?
    var currentCase: CaseData?
    let errorColor = UIColor.red
    let goodColor = UIColor.blue
    let reporters = ["U.S.", "S. Ct."]  // Supreme Court case reporters
    let pickerFont = UIFont.systemFont(ofSize: 16)
    let pickerWidth = CGFloat(50)
    let endpoint = "/clusters/"  // CourtListener API endpoint for case data

    // UI references
    @IBOutlet weak var someView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var volField: NumberField!
    @IBOutlet weak var pageField: NumberField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var reporterPicker: UIPickerView!
    @IBOutlet weak var vLabel: UILabel!
    @IBOutlet weak var appellantLabel: UILabel!
    @IBOutlet weak var appelleeLabel: UILabel!
    @IBOutlet weak var waitIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        verifyItem()
    }
    
    @IBAction func textEdited(_ sender: NumberField) {
        verifyItem()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        if let c = currentCase {
            addItem(c)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  Set up picker view
        self.reporterPicker.delegate = self
        self.reporterPicker.dataSource = self
        reporterPicker.frame.size.width = pickerWidth
        //  Set up Siesta service
//        let caseURL = myAPI.url + endpoint + "*"
//        myAPI.configureTransformer(caseURL) {
//            CaseData($0.content)
//        }
    }
    
    // MARK: picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .left
        label.font = pickerFont
        label.text = reporters[row]
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        usReporter = (row == 0)
    }
    
    // Display result messages to user
    func displayMessage(_ message: String, _ color: UIColor = UIColor.black) {
        errorLabel.textColor = color
        errorLabel.text = message
    }
    
    func displayError(_ message: String) {
        displayMessage(message, errorColor)
        waitIndicator.stopAnimating()
        submitButton.isEnabled = true
    }
    
    // Submit case for verification and return clid, if found
    func verifyItem() {
        submitButton.isEnabled = false
        usVol = validate(volField)
        usPage = validate(pageField)
        do {
            let c = try Citation(usVol, usPage, usReporter)
            currentCitation = c
            let query = caseQuery(c)
            observer = CLObserver(endpoint, query)
            observer?.delegate = self
            observer?.load()
        }
        catch {
            displayError("Invalid citation")
        }
    }

    // Handle server response
    func resourceChanged(_ resource: Resource) {
        // Verify that response includes case info
        guard let data = resource.latestData?.content  else {
            displayMessage("Verifying, please wait...")
            return
        }
        guard let caseInfo = caseDataFromJSON(JSON(data)) else {
            return
        }
//        print(caseInfo)
        // Display case info
        if let partyList = caseInfo.parties() {
            displayCaseName(partyList)
        }
        if let citation = caseInfo.cite() {
            currentCitation = citation
            currentCase = caseInfo
            self.addButton.isEnabled = true
            displayMessage("Case verified!", goodColor)
        }
        else {
            displayError("Bad citation data")
        }
    }
    
    // Extract case data from JSON response
    func caseDataFromJSON(_ json: JSON) -> CaseData? {
        let caseList = json["results"]
        guard caseList.count != 0 else {
            if currentCitation?.usReporter == false {
                displayError("Try using US Reporter instead")
            }
            else {
                displayError("Citation not found in database")
            }
            return nil
        }
//        print(caseList[0])
        return CaseData(caseList[0])
    }
    
    func displayCaseName(_ partyList: [String]) {
        guard partyList.count == 2 else {
            displayError("Wrong number of parties")
            return
        }
        appellantLabel.text = partyList[0]
        appelleeLabel.text = partyList[1]
        vLabel.text = "v"
    }
    
    // Save item to database
    // TBA:  Need to allow S.Ct. citation as alternative to U.S.
    func addItem(_ c: CaseData) {
        do {
            try save(c)
        }
        catch {
            displayError("Unable to save to database")
        }
    }
    
    func validate(_ n: NumberField) -> Int? {
        if let nText = n.text {
            return Int(nText)
        }
        return nil
    }
    
    func caseQuery(_ c: Citation) -> String {
        let reporter = c.usReporter ? "U.S." : "S.+Ct."
        return "?federal_cite_one=\(c.volume)+\(reporter)+\(c.page)"
    }
    
    // Save case with volume v, page p
    func save(_ c: CaseData) throws {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        guard let cite = c.cite() else {
            displayError("Invalid citation")
            throw SaveError.badCite
        }
        let v = cite.volume
        let p = cite.page
        // This check should be unnecessary now
        guard v > 0 && p > 0 else {
            displayError("Invalid citation")
            throw SaveError.badCite
        }
        
        // Get managed object context to store changes to database
        let managedContext: NSManagedObjectContext =
            appDelegate.persistentContainer.viewContext
        let caseLaw = CaseLaw(context: managedContext)
        if cite.usReporter {
            caseLaw.usVol = Int16(v)
            caseLaw.usPage = Int16(p)
        }
        else {
            caseLaw.sctVol = Int16(v)
            caseLaw.sctPage = Int16(p)
        }
        if let clId = c.id {
            caseLaw.clId = Int32(clId)
        }
        if let appellant = c.party(0) {
            caseLaw.appellant = appellant
        }
        if let appellee = c.party(1) {
            caseLaw.appellee = appellee
        }
        caseLaw.timestamp = Date()
        print(caseLaw.appellant)

        // Save to database
        do {
            try toSave(managedContext)
            
        } catch let error as NSError {
            displayError("Could not save.")
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func toSave(_ managedContext: NSManagedObjectContext) throws {
        try managedContext.save()
        displayMessage("Item added.", goodColor)
        clearForm()
        
        if let tableController = table {
            //                print(tableController)
            //                tableController.people.append(caseLaw)
            tableController.tableView.reloadData()
        }
    }
    
    func clearForm() {
        addButton.isEnabled = false
        submitButton.isEnabled = true
        currentCase = nil
        currentCitation = nil
    }
    
}
