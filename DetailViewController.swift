//
//  DetailViewController.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 6/20/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    @IBOutlet weak var opinionView: UITextView!
    
    //    @IBOutlet weak var webDisplay: CaseDisplay!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        self.displayHTML()
    }
    
    func displayHTML() {
        let cl = QuerySession(self)
        cl.QueryTask(cl.q)

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

