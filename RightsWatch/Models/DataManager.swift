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
        guard let managedContext = getContext() else {
            return
        }
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try managedContext.execute(DelAllReqVar) }
        catch { print(error) }
    }
    
    func saveToDatabase(_ file: CSVReader) {
        guard let managedContext = getContext() else {
            return
        }
        guard let caseList = file.data() else {
            return
        }
        // TBA
    }
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    func fetchCase(_ id: Int) -> CaseLaw? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CaseLaw")
        request.predicate = NSPredicate(format: "clId = %@", String(id))
        request.returnsObjectsAsFaults = false
        do {
            let result = try getContext()?.fetch(request)
            if result == nil || result!.count == 0 {
                return nil
            }
            return result![0] as? CaseLaw

            
        } catch {
            
            print("Failed")
        }
        return nil
    }
}



