//
//  CourtListener.swift
//  Rights Watch
//
//  Created by Jeffrey Roy on 6/16/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//
//  Classes to query CourtListener api and interpret response

import Foundation

enum CLError: Error {
    case noConnection
    case noResponse
    case notJson
    case noURL
}

class QuerySession {
    
    typealias ResponseHandler = (Data?, URLResponse?, Error?) -> Void
    typealias ResponseDisplay = ([String: Any]?) -> Void
    
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
    
    // extract case id from court listener url
    // e.g. ../opinions/4030562/
    func idFromURL(_ url: String) -> Int? {
        // Get components of url
        var urlComponents = url.components(separatedBy: "/")
        // Remove blank entry caused by trailing "/" in url
        if urlComponents.last == "" { urlComponents.removeLast() }
        // Return id if it exists
        if let id = urlComponents.last {
            return Int(id)
        }
        else { return nil }
    }
    
    // Create url query from dictionary
    func query(_ conditions: [String: String]) -> [String] {
        return conditions.map { key, value in (key + "=" + value) }
    }
    
    // Submit query
    func getQuery(_ endpoint: String, _ query: String = "") {
        let path = endpoint + "/?" + query
        do {
            try queryTask(path, displayCase(_:))

        }
        catch {
            print(error)
        }
    }
    
    // Find case by federal citation
    func getCaseByCite(_ volume: Int16, _ page: Int16, _ us: Bool) {
        let citation = "one"
        let reporter = us ? "U.S." : "S.+Ct."
        let query = "federal_cite_\(citation)=\(volume)+\(reporter)+\(page)"
        getQuery("clusters", query)
    }
    
    // Get opinion by opinion id
    func getOpinionById(_ id: Int) {
        let path = "opinions/\(id)"
        getQuery(path)
    }
    
    // Convert json data to dictionary
    func jsonify(_ data: Data) throws -> [String: Any] {
        print("Attempting to convert to json...")
        // Convert the data to JSON
        let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: [])
        // Try to convert to dictionary
        guard let json = jsonSerialized as? [String : Any]  else {
            throw CLError.notJson
        }
        return json
    }
    
    func displayCase(_ jsonDictionary: [String: Any]?) -> Void {
        print("Attempting to display opinion...")
        guard let json = jsonDictionary else {
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
        if let results = json["results"] {
            let r = String(describing: results)
            if let vc = self.viewController {
                DispatchQueue.main.async {
                    vc.opinionView.text = r
                    vc.loadingIndicator.stopAnimating()
                }
            }
        }
    }
    
    func clURL(_ path: String) -> URL? {
        let urlPath = clPath + path
        return URL(string: urlPath)
    }
    
    // Function to submit request to court listener api
    func queryTask(_ path: String, _ displayHandler: ResponseDisplay? = nil) throws {
        // Make sure we have an active session
        guard session != nil else {
            throw CLError.noConnection
        }
        // Create url
        guard let url = clURL(path) else {
            throw CLError.noURL
        }
        print("Submitting request to \(url)")
        
        // Create task to make http request
        let task = session!.dataTask(with: url) { (data, response, error) in
            print("Data task complete")
            if let data = data  {
                do {
                    let json = try self.jsonify(data)
                    if let display = displayHandler {
                        display(json)
                    }
                    else { print("No display handler!")}
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                    print("Network error!")
                }
            }
            else {
                print("Request failed!")
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        
        // Run task
        task.resume()
    }
}

