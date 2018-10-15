//
//  DetailViewController.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 6/20/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//

import UIKit
import Siesta


class DetailViewController: UIViewController, CLDelegate {
    
    var caseId: Int = 0
    var observer: CLObserver?

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    @IBOutlet weak var opinionView: UITextView!
    
    //    @IBOutlet weak var webDisplay: CaseDisplay!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    func configureView() {
        // Update the user interface for the detail item.
        
        guard let detail = detailItem else {
            return
        }
        if let label = detailDescriptionLabel {
            label.text = detail.description
        }
        caseId = Int(detail.id)
        if caseId > 0 {
            // TBA: Get opinion text from CL
        }

    }
    
    private func endpoint() -> String? {
        if caseId > 0 {
            print("/opinions/\(caseId)/")
            return "/opinions/\(caseId)/"
        }
        else {
            print("No case data!")
            opinionView.text = "No case data!"
            opinionView.textColor = UIColor.red
            return nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
//        self.displayHTML()
        print("Creating session...")
        // Use set endpoint for testing purposes
        if let url = endpoint() {
            observer = CLObserver(url) // Add resource listener
            observer?.delegate = self
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Loading data...")
        observer?.load()
    }
    
    // MARK:  Siesta observer
    func resourceChanged(_ resource: Resource) {
        if let text = resource.jsonDict["html_with_citations"] as? String {
//            print(resource.jsonDict)
            displayOpinion(text)
        }
    }
    
    func displayOpinion(_ text: String) {
        opinionView.attributedText = text.htmlToAttributedString
        loadingIndicator.stopAnimating()
    }
    
//
//    func displayHTML() {
//        guard let detail = detailItem else {
//            return
//        }
//        let cl = QuerySession(self)
//        if detail.usVol > 0 && detail.usPage > 0 {
//            cl.getCaseByCite(detail.usVol, detail.usPage, true)
//        }
//        else if detail.sctVol > 0 && detail.sctPage > 0 {
//            cl.getCaseByCite(detail.sctVol, detail.sctPage, false)
//        }
//        else {
//            opinionView.text = "Case not found.  Check citation."
//        }
//    }

    override func  didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: OpinionData? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func citingCases() {
        print("Show cited cases...")
    }
    
    // Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCitingCases" {
            // Format detail view
            let controller = (segue.destination as! UINavigationController).topViewController as! CiteViewController
            controller.caseId = caseId
            print(controller.caseId!)
        }
    }

}

