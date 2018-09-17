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
import PromiseKit // Implements promises
// TBA:  Use Siests instead of promises?

enum SaveError: Error {
    case badCite
    case notFound
}

// Structure to hold basic case citation info
struct Citation {
    var volume: Int
    var page: Int
    var usReporter: Bool  // True if U.S., false if S.Ct.
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
}

class CaseFormViewController: CLViewController, UIPickerViewDataSource, UIPickerViewDelegate {
   
    weak var table: MasterViewController?
    var usPage: Int?
    var usVol: Int?
    var sctPage: Int?
    var sctVol: Int?
    var usReporter: Bool = true
    let badColor = UIColor.red
    let goodColor = UIColor.blue
    let reporters = ["U.S.", "S. Ct."]
    let pickerFont = UIFont.systemFont(ofSize: 16)
    let pickerWidth = CGFloat(50)

    
    @IBOutlet weak var someView: UIView!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var volField: NumberField!
    
    @IBOutlet weak var pageField: NumberField!
    
    @IBAction func textEdited(_ sender: NumberField) {
        addItem()
    }
    
    @IBOutlet weak var vLabel: UILabel!
    
    @IBOutlet weak var appellantLabel: UILabel!
    
    @IBOutlet weak var appelleeLabel: UILabel!
    
    @IBOutlet weak var waitIndicator: UIActivityIndicatorView!
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        addItem()
    }
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var reporterPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reporterPicker.delegate = self
        self.reporterPicker.dataSource = self
        reporterPicker.frame.size.width = pickerWidth
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
    
    
    func displayMessage(_ message: String, _ color: UIColor = UIColor.black) {
        errorLabel.textColor = color
        errorLabel.text = message
    }
    
    // Save item to database
    // TBA:  Need to allow S.Ct. citation as alternative to U.S.
    func addItem() {
        print("Item edited")
        usVol = validate(volField)
        usPage = validate(pageField)
        do {
                let c = try Citation(usVol, usPage, usReporter)
                try save(c)
        }
        catch {
            displayMessage("Invalid citation", badColor)
        }
    }
    
    func validate(_ n: NumberField) -> Int? {
        if let nText = n.text {
            return Int(nText)
        }
        return nil
    }
    
    func getCase(_ c: Citation) -> Promise<CaseLaw> {
        // TBA
        return Promise { _ in }
    }
    
    func caseQueryEndpoint(_ c: Citation) -> String {
        let reporter = c.usReporter ? "U.S." : "S.+Ct."
        return "federal_cite_one=\(c.volume)+\(reporter)+\(c.page)"
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
            displayMessage("Invalid citation", badColor)
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
        caseLaw.timestamp = Date()


        // Save to database
        do {
            try toSave(managedContext)
            
        } catch let error as NSError {
            displayMessage("Could not save.", badColor)
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func toSave(_ managedContext: NSManagedObjectContext) throws {
        try managedContext.save()
        displayMessage("Item added.", goodColor)
        
        if let tableController = table {
            //                print(tableController)
            //                tableController.people.append(caseLaw)
            tableController.tableView.reloadData()
        }
    }
    
    
}
