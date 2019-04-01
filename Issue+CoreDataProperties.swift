//
//  Issue+CoreDataProperties.swift
//  
//
//  Created by Jeffrey Roy on 11/16/18.
//
//

import Foundation
import CoreData


extension Issue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Issue> {
        return NSFetchRequest<Issue>(entityName: "Issue")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var issueCase: NSSet?

}

// MARK: Generated accessors for issueCase
extension Issue {

    @objc(addIssueCaseObject:)
    @NSManaged public func addToIssueCase(_ value: CaseLaw)

    @objc(removeIssueCaseObject:)
    @NSManaged public func removeFromIssueCase(_ value: CaseLaw)

    @objc(addIssueCase:)
    @NSManaged public func addToIssueCase(_ values: NSSet)

    @objc(removeIssueCase:)
    @NSManaged public func removeFromIssueCase(_ values: NSSet)

}
