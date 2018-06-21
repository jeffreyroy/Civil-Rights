//
//  CourtListener.swift
//  Rights Watch
//
//  Created by Jeffrey Roy on 6/16/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//
//  Classes to query CourtListener api and interpret response

import Foundation

class QuerySession {
    
    //let path = "https://words.bighugelabs.com/api/2/\(bhlKey)/\(word)/\(format)"
    let path = "https://www.courtlistener.com/api/rest/v3/opinions/2812209/"
    //let path = "https://\(un):\(pw)@www.courtlistener.com/api/rest/v3/clusters/?federal_cite_one=135+S.+Ct.+2584"
    let clAuth = "Token " + clKey
    var session: URLSession?
    
    init() {
        
        // Create default session configuration
        let config = URLSessionConfiguration.default
        
        // Add authorization
        config.httpAdditionalHeaders = ["Authorization" : clAuth, "Accept" : "application/json"]
        
        // Create new session
        session = URLSession(configuration: config)
        
    }
    
    func QueryTask() {
        guard session != nil else {
            print("No url session")
            return
        }
        
        let url = URL(string: path)
        // Create task to make http request
        
        let task = session!.dataTask(with: url!) { (data, response, error) in
            print("Data task complete")
            if let data = data  {
                
                do {
                    print("Attempting to convert to json...")
                    //            let htmlPage: NSAttributedString? = NSAttributedString(html: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: [])
                    // Try to convert to dictionary
                    guard let json = jsonSerialized as? [String : Any]  else {
                        // throw error
                        return
                    }
                    print(json)
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            else {
                print("Request failed!")
                print(error)
            }
            
        }
        
        // Run task
        task.resume()
    }
}

