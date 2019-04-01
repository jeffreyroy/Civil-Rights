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
    var detailItem: OpinionData? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    @IBOutlet weak var opinionView: UITextView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var citeButton: UIBarButtonItem!
    
    @IBAction func citeAction(_ sender: UIBarButtonItem) {
        print("Cite button pressed")
    }
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    func configureView() {
        // Update the user interface for the detail item.
        guard let detail = detailItem else {
            return
        }
        if let nav = navigationBar {
            nav.title = detail.description
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
//        displayActionSheet()
    }
    
    // MARK:  Siesta observer
    func resourceChanged(_ resource: Resource) {
        print(resource.jsonDict.keys)
        if let text = resource.jsonDict["html_with_citations"] as? String {

            displayOpinion(text)
            displayActionSheet()

        }
    }
    
    func displayOpinion(_ text: String) {
//        opinionView.setZoomScale(4.0, animated: false)
        opinionView.attributedText = text.htmlToAttributedString
        loadingIndicator.stopAnimating()
    }
    
    override func  didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    // Action alert
    func displayActionSheet() {
        guard detailItem?.sct == true else {
            return
        }
        
        let dm = DataManager()
        guard dm.fetchCase(caseId) == nil else {
            return
        }
        
        
        let optionMenu = UIAlertController(title: nil, message: "Add case to database?", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: saveButton)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelButton)
        
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func saveButton(_ action: UIAlertAction) {
        performSegue(withIdentifier: "addCaseSegue", sender: nil)
    }
    
    func cancelButton(_ action: UIAlertAction) {
        print("Cancel button pressed")
    }
    
    // Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCitingCases" {
            // Format detail view
            let controller = (segue.destination as! UINavigationController).topViewController as! CiteViewController
            controller.caseId = caseId
            print(controller.caseId!)
        }
        if segue.identifier == "addCaseSegue" {
            let controller = segue.destination as! CaseFormViewController
            // TBA:  Add cite info to destination
            controller.currentCaseId = caseId
        }
    }
    
}



