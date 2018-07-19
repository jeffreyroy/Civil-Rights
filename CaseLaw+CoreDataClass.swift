//
//  Case+CoreDataClass.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 6/24/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CaseLaw)
public class CaseLaw: NSManagedObject {
    
    // Validate entry before saving to database
    public override func validateForInsert() throws {
        try super.validateForInsert()
        // TBA
    }
    
    // Display case citation
    override public var description: String {
        return "\(t(usVol)) U.S. \(t(usPage)),  \(t(sctVol)) S.Ct. \(t(sctPage))"
    }
    
    // Replace nil values with blank
    private func t(_ i: Int16?) -> String {
        if let number = i {
            if number > 0 { return String(describing: number) }
        }
        return "___"
    }
    

}


