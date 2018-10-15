//
//  DetailViewController.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 6/20/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//
//  Detail view displays text of opinion

import UIKit
import Siesta

class DetailViewController: UIViewController, CLDelegate {
    var caseId: Int = 0
    var observer: CLObserver?

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var opinionView: UITextView!
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
        print("Creating session...")
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

