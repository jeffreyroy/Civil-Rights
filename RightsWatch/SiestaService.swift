//
//  SiestaService.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 9/15/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//

import Foundation
import Siesta

// Siesta Services
class CLAPI: Service {
    init(baseURL: String) {
        super.init(baseURL: baseURL)
        
        // Global default headers
        configure {
            $0.headers["Authorization"] = clKey
        }
    }
}

class CLViewController: UIViewController, ResourceObserver {
    let MyAPI = CLAPI(baseURL: "https://www.courtlistener.com/api/rest/v3")
    var endpoint: String = ""  // Customize this
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        // Override this for individual controller
    }
    
    func setAPI() {
        MyAPI.resource(endpoint).addObserver(self)
    }
    
    func getAPI() {
        MyAPI.resource(endpoint).loadIfNeeded()
    }
}
