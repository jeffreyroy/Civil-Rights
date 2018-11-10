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
    var active: Bool = true
    weak var table: MasterViewController?
    var observer: CLObserver?
    var usPage: Int?
    var usVol: Int?
    var sctPage: Int?
    var sctVol: Int?
    var usReporter: Bool = true
    var currentCitation: Citation?
    var currentCase: CaseData?
    var currentCaseId: Int?
    let errorColor = UIColor.red
    let goodColor = UIColor.blue
    let reporters = ["U.S.", "S. Ct."]  // Supreme Court case reporters
    let pickerFont = UIFont.systemFont(ofSize: 16)
    let pickerWidth = CGFloat(50)
    let endpoint = "/clusters/"  // CourtListener API endpoint for case data

    @IBAction func swipeLeft(_ sender: UIScreenEdgePanGestureRecognizer) {
        segueRight()
        print("swipe detected!")

    }
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
        if currentCaseId != nil {
            displayError("Verifying item...")
            verifyItem()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        active = true
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
    func displayMessage(_ message: String, _ color: UIColor = UIColor.blue) {
        errorLabel.textColor = color
        errorLabel.text = message
    }
    
    func displayError(_ message: String) {
        displayMessage(message, errorColor)
        waitIndicator.stopAnimating()
        submitButton.isEnabled = true
    }
    
    // Submit case for verification
    func verifyItem() {
        submitButton.isEnabled = false
        waitIndicator.startAnimating()
        usVol = validate(volField)
        usPage = validate(pageField)
        do {
            if let id = currentCaseId {
                observer = CLObserver(endpoint + "\(id)/")
            }
            else {
                let c = try Citation(usVol, usPage, usReporter)
                currentCitation = c
                let query = caseQuery(c)
                observer = CLObserver(endpoint, query)
            }
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
        waitIndicator.stopAnimating()
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
        // If only one case, return it
        if json["id"].intValue == currentCaseId {
            return CaseData(json)
        }
        // Otherwise, check for list of cases
        let caseList = json["results"]
        if caseList.count == 0  {
            if currentCitation?.usReporter == false {
                displayError("Try using US Reporter instead")
            }
            else {
                displayError("Citation not found in database")
            }
            return nil
        }
        // Return first case in list
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
    
    // Save case to database
    func save(_ c: CaseData) throws {
        // Get managed object context to store changes to database
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext: NSManagedObjectContext =
            appDelegate.persistentContainer.viewContext
        let caseLaw = CaseLaw(context: managedContext)
        // Import case data
        do {
            try caseLaw.importData(c)
        } catch let error as NSError {
            displayError("Invalid citation.")
            print("Could not save. \(error), \(error.userInfo)")
        }
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
            tableController.tableView.reloadData()
        }
    }
    
    func clearForm() {
        addButton.isEnabled = false
        submitButton.isEnabled = true
        currentCase = nil
        currentCitation = nil
    }
    
    func segueRight() {
        if active {
            performSegue(withIdentifier: "panelSegue", sender: self)
            active = false
        }

    }
    
}
