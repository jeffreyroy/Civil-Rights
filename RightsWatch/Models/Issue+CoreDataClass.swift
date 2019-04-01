//
//  Issue+CoreDataClass.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 11/16/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Issue)
public class Issue: NSManagedObject {

    // Display case citation
    override public var description: String {
        return name != nil ? name! : "(No description)"
    }
}
