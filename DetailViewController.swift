//
//  DetailViewController.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 6/20/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var caseId: Int = 0

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
        caseId = Int(detail.clId)
        if caseId > 0 {
            // TBA: Get opinion text from CL
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        self.displayHTML()
    }
    
    
    
    func displayHTML() {
        guard let detail = detailItem else {
            return
        }
        let cl = QuerySession(self)
        if detail.usVol > 0 && detail.usPage > 0 {
            cl.getCaseByCite(detail.usVol, detail.usPage, true)
        }
        else if detail.sctVol > 0 && detail.sctPage > 0 {
            cl.getCaseByCite(detail.sctVol, detail.sctPage, false)
        }
        else {
            opinionView.text = "Case not found.  Check citation."
        }
    }

    override func  didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: CaseLaw? {
        didSet {
            // Update the view.
            configureView()
        }
    }

}

