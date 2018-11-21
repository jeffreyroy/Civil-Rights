//
//  CSVReader.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 11/9/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//
//  Read data from CSV file into [[String]] array

import Foundation


// Separate string into array of strings, rather than substrings
extension String {
    func divide(separator s: Character) -> [String] {
        let array = split(separator: s)
        return array.map { String($0) }
    }
}

// Remove duplicate elements of array
// Taken from https://stackoverflow.com/questions/25738817/removing-duplicate-elements-from-an-array-in-swift/46354989#46354989
public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}

// WordList class to import words from file
class CSVReader {
    var parsed: Bool = false
    let bundle = Bundle.main  // Project directory

    var parsedData: [[String]] = []
    init(_ fileName: String) {
        guard let inString = readFrom(fileName) else {
            return
        }
        parsedData = parse(inString)
        print("Read from the file: \(parsedData.count) lines")
    }
    
    // Try to read data from file
    func readFrom(_ fileName: String) -> String? {

        print("Reading \(fileName)...")
        var fileContents = ""

        guard let fileURL = bundle.path(forResource: fileName, ofType: "csv") else {
            print("Can't find file \(fileName)")
            return nil
        }
        do {
            fileContents = try String(contentsOfFile: fileURL, encoding: .utf8)
        } catch {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        
        parsed = true
        // String quotation marks and return string
        return fileContents.replacingOccurrences(of: "\"", with: "")
    }
    
    // Parse data into array
    func parse(_ s: String) -> [[String]] {
        print("parsing...")
        let wordList = s.divide(separator: "\n")
        return wordList.map { $0.divide(separator: ",") }
    }
    
    func data() -> [[String]]? {
        return parsed ? parsedData : nil
    }
    
    // Attempt to find column title in first row of data,
    // and return index
    func columnIndex(_ title: String) -> Int? {
        guard parsed else {
            print("Not ready")
            return nil }
        guard parsedData.count > 0 else {
            print("No data")
            return nil }
        let top = parsedData[0]
        print(top)
        return top.index(of: title)
    }
    
    // Search for items with a specified value in specified
    // column
    func filterData(_ column: Int, _ value: String) {
        parsedData = parsedData.filter { $0.count > column && $0[column] == value }
    }
    
    // Eliminate duplicates
    func makeUnique(_ column: Int) {
        var newData: [[String]] = []
        for (index, row) in parsedData.enumerated() {
            if parsedData.index(where: {$0[column] == row[column]}) == index {
                newData.append(row)
            }
        }
    }
    
    // Column headings:
    // caseName
    // usCite
    // sctCite
    
    
    
}

