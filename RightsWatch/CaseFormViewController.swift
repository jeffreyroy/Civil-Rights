//
//  CaseFormViewController.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 6/29/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//

import UIKit
import CoreData // API for interacting with database

class CaseFormViewController: UIViewController {
    
    weak var table: MasterViewController?
    var page: Int?
    var vol: Int?
    let badColor = UIColor.red
    let goodColor = UIColor.blue
    
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
    
    
    func displayMessage(_ message: String, _ color: UIColor = UIColor.black) {
        errorLabel.textColor = color
        errorLabel.text = message
    }
    
    func addItem() {
        print("Item edited")
        if let volText = volField.text {
            vol = Int(volText)
        }
        if let pageText = pageField.text {
            page = Int(pageText)
        }
        if vol != nil && page != nil {
            save(vol!, page!)
        }
        else {
            displayMessage("Invalid citation", badColor)
        }
    }
    
    // Save case with volume v, page p
    func save(_ v: Int, _ p: Int) {
        
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
        caseLaw.usVol = Int16(v)
        caseLaw.usPage = Int16(p)
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
