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
class CLAPI: Service {
    let url = "https://www.courtlistener.com/api/rest/v3"
    init() {
        super.init(baseURL: url)
        // Global default headers
        configure {
            $0.headers["Authorization"] = clKey
        }
    }
}

class CLViewController: UIViewController, ResourceObserver {
    let myAPI = CLAPI()

    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        // Override this for individual controller
    }
    
    func setAPI(_ endpoint: String, _ query: String? = nil) {
        if let q = query {
            myAPI.resource(endpoint).relative(q).addObserver(self)
        }
        else {
            myAPI.resource(endpoint).addObserver(self)
        }
    }
    
    func getAPI(_ endpoint: String, _ query: String? = nil) {
    
        if let q = query {
            myAPI.resource(endpoint).relative(q).loadIfNeeded()
        }
        else {
            myAPI.resource(endpoint).loadIfNeeded()
        }
    }
}
