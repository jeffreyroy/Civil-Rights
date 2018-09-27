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
import Siesta // Implements promises
import SwiftyJSON
// TBA:  Use Siests instead of promises?

enum SaveError: Error {
    case badCite
    case notFound
}

// MARK: Structures to hold basic case citation info
struct Citation {
    var volume: Int
    var page: Int
    var usReporter: Bool  // True if U.S., false if S.Ct.
    var id: Int?  // CourtListener id, if it exists
    var appellant: String?
    var appellee: String?

    // Verify citation form when initializing, throw error if
    // not a valid citation
    init(_ v: Int?, _ p: Int?, _ us: Bool = true) throws {
        guard v != nil && p != nil else {
            throw SaveError.badCite
        }
        guard v! > 0 && p! > 0 else {
            throw SaveError.badCite
        }
        self.volume = v!
        self.page = p!
        self.usReporter = us
    }
    
    func title() -> String? {
        if appellant != nil && appellee != nil {
            return appellant! + " v " + appellee!
        }
        else { return nil }
    }
}

struct CaseData {
    var id: Int?
    var federalCiteOne: String?
    var caseName: String?
    init(_ json: JSON) {
        self.federalCiteOne = json["federal_cite_one"].stringValue
        self.caseName = json["case_name"].stringValue
        self.id = json["id"].int
    }
    
    // Split string using a string as separator
    private func split(_ text: String, _ divider: String) -> [String] {
        let separator: Character = "%"
        let separable = text.replacingOccurrences(of: divider, with: String(separator))
        return separable.split(separator: separator).map { String($0) }
    }
    
    // Separate name into list of parties
    func parties() -> [String]? {
        let versus = " v. "
        // Check to make sure name is in correct form
        guard let name = caseName else {
            print("No case name")
            return nil
        }
        guard let _ = name.range(of: versus) else {
            print("Can't parse case name")
            return nil
        }
        // Separate name and return list of parties
        return split(caseName!, versus)
    }
    
    // Return a specific party (0 = appellant, 1 = appellee)
    func party(_ p: Int) -> String? {
        guard let partyList = parties() else {
            return nil
        }
        guard partyList.count > p else {
            return nil
        }
        return partyList[p]
    }
    
    // Extract page and volume from citation
    func cite() -> Citation? {
        var citeData: [String]
        var us: Bool
        guard let citation = federalCiteOne else {
            print("No citation")
            return nil
        }
        let usSplit = split(citation, " U.S. ")
        let sCtSplit = split(citation, " S. Ct. ")
        if usSplit.count == 2 { citeData = usSplit; us = true }
        else if sCtSplit.count == 2 { citeData = sCtSplit; us = false }
        else { return nil }
        do {
            return try Citation(Int(citeData[0]), Int(citeData[1]), us)
        }
        catch {
            print(error)
            return nil
        }
    }
    
}

// MARK: Controller for case form view
class CaseFormViewController: CLViewController, UIPickerViewDataSource, UIPickerViewDelegate {
   
    // MARK: Variables
    weak var table: MasterViewController?
    var usPage: Int?
    var usVol: Int?
    var sctPage: Int?
    var sctVol: Int?
    var usReporter: Bool = true
    var currentCitation: Citation?
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
        if let c = currentCitation {
            addItem(c)
        }
    }
    

    
    // MARK: Set up
    override func viewDidLoad() {
        super.viewDidLoad()
        //  Set up picker view
        self.reporterPicker.delegate = self
        self.reporterPicker.dataSource = self
        reporterPicker.frame.size.width = pickerWidth
        //  Set up Siesta service
        let caseURL = myAPI.url + endpoint + "*"
//        myAPI.configureTransformer(caseURL) {
//            CaseData($0.content)
//        }
    }
    
    
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
            let query = caseQuery(c)
            setAPI(endpoint, query)
            getAPI(endpoint, query)

        }
        catch {
            displayError("Invalid citation")
        }
    }

    // Handle server response
    override func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        guard let data = resource.latestData?.content  else {
            displayMessage("Verifying, please wait...")
            return
        }
        // Parse JSON
        let json = JSON(data)
        let caseList = json["results"]
        guard caseList.count != 0 else {
            displayError("No cases listed in results?!")
            return
        }
        print(caseList[0])
        let caseInfo = CaseData(caseList[0])
        if let partyList = caseInfo.parties() {
            displayCaseName(partyList)
        }
        if let citation = caseInfo.cite() {
            currentCitation = citation
            self.addButton.isEnabled = true
            displayMessage("Case verified!", goodColor)
        }
        else {
            displayError("Bad citation data")
        }

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
    func addItem(_ c: Citation) {
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
    
//    func getCase(_ c: Citation) -> Promise<CaseLaw> {
//        // TBA
//        return Promise { _ in }
//    }
    
    func caseQuery(_ c: Citation) -> String {
        let reporter = c.usReporter ? "U.S." : "S.+Ct."
        return "?federal_cite_one=\(c.volume)+\(reporter)+\(c.page)"
    }
    
    // Save case with volume v, page p
    func save(_ c: Citation) throws {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let v = c.volume
        let p = c.page
        // This check should be unnecessary now
        guard v > 0 && p > 0 else {
            displayError("Invalid citation")
            throw SaveError.badCite
        }
        
        // Get managed object context to store changes to database
        let managedContext: NSManagedObjectContext =
            appDelegate.persistentContainer.viewContext
        let caseLaw = CaseLaw(context: managedContext)
        if c.usReporter {
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
        caseLaw.timestamp = Date()


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
    }
    
}
