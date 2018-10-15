//
//  SiestaService.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 9/15/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//
//  Defines classes to query CourtListener API

import Foundation
import Siesta

// Siesta Services

// Create service to access CourtListener
class CLAPI: Service {
    let url = "https://www.courtlistener.com/api/rest/v3"
    init() {
        super.init(baseURL: url)
        // Global default headers
        configure {
            $0.headers["Authorization"] = clKey
            $0.headers["Accept"] = "application/json"
        }
    }
}

// CLObserver class submits query to api
// CLDelegate processes response
protocol CLDelegate: class {
    func resourceChanged(_ resource: Resource)
}

class CLObserver: ResourceObserver {
    let myAPI = CLAPI()
    var endpoint: String
    var query: String?
    weak var delegate: CLDelegate?
    
    init(_ e: String, _ q: String? = nil) {
        endpoint = e
        query = q
        if let q = query {
            myAPI.resource(endpoint).relative(q).addObserver(self)
        }
        else {
            myAPI.resource(endpoint).addObserver(self)
        }
    }
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        print("Resource changed!")
        print(resource.url)
        delegate?.resourceChanged(resource)
    }
    
    func load() {
        print("Loading resource from \(endpoint)...")
        if let q = query {
            print("/\(q)")
            myAPI.resource(endpoint).relative(q).loadIfNeeded()
        }
        else {
            myAPI.resource(endpoint).loadIfNeeded()
        }
    }
    
    // Extract case id from CourtListener url
    func name(from url: String) -> String? {
        // Separate url into parts
        var array = url.components(separatedBy: "/")
        print(array)
        // Penultimate element should be id, if it exists
        if array.count <= 1 { return nil }
        array.removeLast()
        return array.last!
    }
    
    func id(from url: String) -> Int? {
        guard let name = name(from: url) else {
            return nil
        }
        return Int(name)
    }
}
