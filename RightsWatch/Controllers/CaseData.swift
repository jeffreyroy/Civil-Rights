//
//  CaseData.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 9/26/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//

import Foundation
import SwiftyJSON


// MARK: Structures to hold basic case citation info
// Opinion stores data received from CourtListener for
// a specific opinion
struct OpinionData {
    var title: String?
    var id: Int
    init(_ i: Int) {
        id = i
        title = String(i)
    }
    public var description: String {
        // Return title if it exists, otherwise id
        return title != nil ? title! : String(id)
    }
}

// Citation stores information for submitted form
struct Citation {
    var volume: Int
    var page: Int
    var usReporter: Bool  // True if U.S., false if S.Ct.
    
    // Verify citation form when initializing, throw error if
    // not a valid citation
    init(_ v: Int?, _ p: Int?, _ us: Bool = true) throws {
        guard v != nil && p != nil else {
            throw SaveError.badCite
        }
        guard v! > 0 && p! > 0 else {
            throw SaveError.badCite
        }
        self.volume = v!
        self.page = p!
        self.usReporter = us
    }
    
    // Display case citation
    public var description: String {
        let reporter = usReporter ? "U.S." : "S.Ct."
        return "\(volume) \(reporter) \(page)"
    }
}

// CaseData stores data receieved from CourtListener
// for a specific case
struct CaseData {
    var id: Int?
    var federalCiteOne: String?
    var federalCiteTwo: String?
    var caseName: String?
    init(_ json: JSON) {
        self.federalCiteOne = json["federal_cite_one"].stringValue
        self.federalCiteTwo = json["federal_cite_"].stringValue
        self.caseName = json["case_name"].stringValue
        self.id = json["id"].int
    }
    
    // Split string using a string as separator
    private func split(_ text: String, _ divider: String) -> [String] {
        let separator: Character = "%"
        let separable = text.replacingOccurrences(of: divider, with: String(separator))
        return separable.split(separator: separator).map { String($0) }
    }
    
    // Separate name into list of parties
    func parties() -> [String]? {
        let versus = " v. "
        // Check to make sure name is in correct form
        guard let name = caseName else {
            print("No case name")
            return nil
        }
        guard let _ = name.range(of: versus) else {
            print("Can't parse case name")
            return nil
        }
        // Separate name and return list of parties
        return split(caseName!, versus)
    }
    
    // Return a specific party (0 = appellant, 1 = appellee)
    func party(_ p: Int) -> String? {
        guard let partyList = parties() else {
            return nil
        }
        guard partyList.count > p else {
            return nil
        }
        return partyList[p]
    }
    
    // Extract page and volume from federal cite
    func cite() -> Citation? {
        var citeData: [String]
        var us: Bool
        guard let citation = federalCiteOne else {
            print("No citation")
            return nil
        }
        let usSplit = split(citation, " U.S. ")
        let sCtSplit = split(citation, " S. Ct. ")
        if usSplit.count == 2 { citeData = usSplit; us = true }
        else if sCtSplit.count == 2 { citeData = sCtSplit; us = false }
        else { return nil }
        do {
            return try Citation(Int(citeData[0]), Int(citeData[1]), us)
        }
        catch {
            print(error)
            return nil
        }
    }
}
