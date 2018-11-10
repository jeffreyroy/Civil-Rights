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
    
    func resetDatabase() {
        print("Deleting all cases from database...")
        let resetter = DataManager()
        resetter.deleteAllData("CaseLaw")
    }
    
    func importData() {
        let dict = CSVReader("SCDB")
        let issue = dict.columnIndex("issue")!
        let name = dict.columnIndex("caseName")!
        
        let religion = "30160"
        let campaign = "30140"
        dict.filterData(issue, campaign)
        print(dict.data()?.count)
//        for row in dict.data() {
//            print(row[name])
//        }
    }
    
}
