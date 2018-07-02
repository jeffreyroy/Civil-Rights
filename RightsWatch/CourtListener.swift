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
    let clPath = "https://www.courtlistener.com/api/rest/v3/"
    let pwPath = "https://\(un):\(pw)@www.courtlistener.com/api/rest/v3/"
    let q = "opinions/2812209/"
    let f = "?format=json"
    //let path = "https://\(un):\(pw)@www.courtlistener.com/api/rest/v3/clusters/?federal_cite_one=135+S.+Ct.+2584"
    let clAuth = "Token \(clKey)"
    let pwAuth = "\(un):\(pw)"
    var session: URLSession?
    var viewController: DetailViewController?
    
    init(_ controller: DetailViewController) {
        
        // Create default session configuration
        let config = URLSessionConfiguration.default
        
        // Add authorization
        config.httpAdditionalHeaders = ["Authorization" : clAuth, "Accept" : "application/json"]
        
        // Create new session
        session = URLSession(configuration: config)
        
        viewController = controller
        
    }
    
    func QueryTask(_ path: String) {
        // Make sure we have an active session
        guard session != nil else {
            print("No url session")
            return
        }
        // Create url
        let urlPath = clPath + path
        let url = URL(string: urlPath)
        
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
                    if let plainText = json["plain_text"] as? String {
                        if let vc = self.viewController {
                           DispatchQueue.main.async {
                                vc.opinionView.attributedText = plainText.htmlToAttributedString
                                vc.loadingIndicator.stopAnimating()
                            }
                        }
                        print("Opinion length: \(plainText.count)")
                    }
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

