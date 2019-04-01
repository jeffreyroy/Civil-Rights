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
        if appellant != nil && appellee != nil {
            return "\(appellant!) v \(appellee!)"
        }
        else if usVol > 0 {
            return "\(t(usVol)) U.S. \(t(usPage))"
        }
        return "\(t(sctVol)) S.Ct. \(t(sctPage))"
    }
    
    // Replace nil values with blank
    private func t(_ i: Int16?) -> String {
        if let number = i {
            if number > 0 { return String(describing: number) }
        }
        return "___"
    }
    
    func importData(_ c: CaseData) throws {
        guard let cite = c.cite() else {
//            displayError("Invalid citation")
            throw SaveError.badCite
        }
        let v = cite.volume
        let p = cite.page
        // This check should be unnecessary now
        guard v > 0 && p > 0 else {
//            displayError("Invalid citation")
            throw SaveError.badCite
        }
        if cite.usReporter {
            usVol = Int16(v)
            usPage = Int16(p)
        }
        else {
            sctVol = Int16(v)
            sctPage = Int16(p)
        }
        if let id = c.id {
            clId = Int32(id)
        }
        if let firstParty = c.party(0) {
            appellant = firstParty
        }
        if let secondParty = c.party(1) {
            appellee = secondParty
        }
        timestamp = Date()
        print(appellant)

    }

}


