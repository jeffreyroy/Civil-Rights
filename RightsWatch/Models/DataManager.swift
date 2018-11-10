//
//  DataManager.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 11/9/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//
//  Reset and seed database

import Foundation
import UIKit
import CoreData // API for interacting with database

class DataManager {
    // Delete core data for entity
    // From https://stackoverflow.com/questions/24658641/ios-delete-all-core-data-swift
    func deleteAllData(_ entity: String)
    {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext: NSManagedObjectContext =
            appDelegate.persistentContainer.viewContext
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print(error) }
    }
    
    func saveToDatabase(_ file: CSVReader) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext: NSManagedObjectContext =
            appDelegate.persistentContainer.viewContext
        guard let caseList = file.data() else {
            return
        }
        // TBA
    }
}



