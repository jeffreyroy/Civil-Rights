//
//  PanelViewController.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 11/10/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//

import Foundation
import UIKit
import CoreData // API for interacting with database


class PanelViewController: UIViewController {
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        resetDatabase()
    }
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBAction func importButtonPressed(_ sender: UIButton) {
        importData()
    }
    
    @IBAction func importIssuesPressed(_ sender: UIButton) {
        importIssues()

    }
    
    @IBAction func printIssuesPressed(_ sender: UIButton) {
        printIssues()
    }
    
    @IBOutlet weak var blurb: UILabel!
    
    func resetDatabase() {
        blurb.text = "Resetting database..."
        let resetter = DataManager()
        resetter.deleteAllData("CaseLaw")
        resetter.deleteAllData("Issue")
    }
    
    func importData() {
        blurb.text = "Reading database files..."

        let dict = CSVReader("SCDB")
        let issue = dict.columnIndex("issue")!
        let name = dict.columnIndex("caseName")!
        let usCite = dict.columnIndex("usCite")!

        let religion = "30160"
        let campaign = "30140"
        blurb.text = "Filtering data..."
        dict.filterData(issue, campaign)
        print(dict.data()!.count)
        for row in dict.data()! {
            print(row[name])
            print(row[usCite])

        }
        blurb.text = "Done!"

    }
    
    func importIssues() {
        blurb.text = "Reading database files..."
        guard let list = readIssues() else {
            blurb.text = "Can't find issue list!"
            return
        }
        writeIssues(list)
        blurb.text = "Done!"
    }
    
    func readIssues() -> [[String]]? {
        let dict = CSVReader("Issues")
        return dict.data()
    }
    
    func writeIssues(_ list: [[String]]) {
        // Get managed object context to store changes to database
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext: NSManagedObjectContext =
            appDelegate.persistentContainer.viewContext
        var issues: [Issue] = []
        // Add issues
        for row in list {
            guard let id = Int32(row[0]) else {
                continue
            }
            let issue = Issue(context: managedContext)
            issue.id = id
            issue.name = row[1]
            issues.append(issue)
        }
        print("Attempting to add \(issues.count) issues to database...")
        // Save to database
        do {
            try toSave(managedContext)
        } catch let error as NSError {
            blurb.text = "Could not save issues"
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func toSave(_ managedContext: NSManagedObjectContext) throws {
        try managedContext.save()
        blurb.text = "Issues added"
    }
    
    func getIssues(_ managedContext: NSManagedObjectContext) -> [Issue] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Issue")
        request.returnsObjectsAsFaults = false
        do {
            let result = try managedContext.fetch(request) as! [Issue]
            print(result.count)
            return result
            
        } catch {
            
            print("Failed")
        }
        return []
    }
    
    func printIssues() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext: NSManagedObjectContext =
            appDelegate.persistentContainer.viewContext
        let list = getIssues(managedContext)
        guard list.count > 0 else {
            print("no issues in database")
            return
        }
        for issue in list {
            print(issue.name!)
        }
    }
}
