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
    override public var description: String {
        return "\(usVol) U.S. \(usPage)"
    }

}


