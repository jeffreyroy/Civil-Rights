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

class CaseFormViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
   
    
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
    
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        addItem()
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
    func addItem() {
        print("Item edited")
        usVol = validate(volField)
        usPage = validate(pageField)

        if usVol != nil && usPage != nil {
            save(usVol!, usPage!, usReporter)
        }
        else {
            displayMessage("Invalid citation", badColor)
        }
    }
    
    func validate(_ n: NumberField) -> Int? {
        if let nText = n.text {
            return Int(nText)
        }
        return nil
    }
    
    // Save case with volume v, page p
    func save(_ v: Int, _ p: Int, _ us: Bool = true) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        guard v > 0 && p > 0 else {
            displayMessage("Invalid citation", badColor)
            return
        }
        
        // Get managed object context to store changes to database
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let caseLaw = CaseLaw(context: managedContext)
        if us {
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
            try managedContext.save()
            displayMessage("Item added.", goodColor)

            if let tableController = table {
//                print(tableController)
//                tableController.people.append(caseLaw)
                tableController.tableView.reloadData()
            }
            
        } catch let error as NSError {
            displayMessage("Could not save.", badColor)
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
}
