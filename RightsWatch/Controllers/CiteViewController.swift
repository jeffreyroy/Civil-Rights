//
//  CiteViewController.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 9/26/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//

import UIKit
import Siesta
import SwiftyJSON

class DataObserver: CLObserver {
    weak var controller: CiteViewController?
    override func resourceChanged(_ resource: Resource, event: ResourceEvent) {
//        print("Resource URL: \(resource.url)")
        // Verify that response includes citing opinion
        guard let data = resource.latestData?.content  else {
            print("No data")
//            print(resource.latestError)
            return
        }
        let absoluteURL = JSON(data)["absolute_url"].stringValue
        // Extract case title from response
        guard let title = name(from: absoluteURL)  else {
            return
        }
        let formatted = title.replacingOccurrences(of: "-", with: " ").uppercased()
//        print(formatted)
        guard let element = name(from: String(describing: resource.url)) else {
            return
        }
        guard let c = controller else {
            return
        }
        // Replace id with name of case in table view
        guard let index = c.caseList!.index(where: {$0.description == element}) else {
            return
        }
        c.caseList![index].title = formatted
        // Reload the table view
        c.citeTable.reloadData()
        // Remove this observer from list of active observers
        if let myIndex = c.dataObservers.index(where: {$0.endpoint == self.endpoint}) {
            c.dataObservers.remove(at: myIndex)
        }
    }
}


class CiteViewController: UITableViewController, CLDelegate {

    var caseId: Int?
//    var caseList: [Citation]?
    var caseList: [OpinionData]?
    let endpoint = "opinions-cited"
    var observer: CLObserver?
    var dataObservers: [DataObserver] = []
    var maxCasesInList = 10  // Maximum number of cases to display in table
//    var dataDelegate: DataDelegate?
    
    @IBOutlet weak var titleLabel: UINavigationItem!
    
    @IBOutlet var citeTable: UITableView!
    
    func query() -> String? {
        return caseId != nil ?  "?fields=citing_opinion&cited_opinion__id=\(caseId!)" : nil
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        guard let label = titleLabel else { return }
        guard let id = caseId else { return }
//        label.title = "Cases citing \(id)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        //        self.displayHTML()
        print("Creating session...")
        // Use set endpoint for testing purposes
        if let q = query() {
            observer = CLObserver(endpoint, q)  // Add resource listener
            observer?.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observer?.load()
    }
    
    // Update table based on response
    func resourceChanged(_ resource: Resource) {
//        print(resource.jsonDict)
        // Verify that response includes data
        guard let data = resource.latestData?.content  else {
            print("No data")
            return
        }
        // Get array of case data
        let results = JSON(data)["results"]
        var list = results.arrayValue
        guard list.count > 0 else {
            print("No citing cases")
            return
        }
        if list.count > maxCasesInList { list = Array(list.prefix(upTo: maxCasesInList)) }
        // Extract case id from data
        let stringList = list.map { $0["citing_opinion"].stringValue }
        var idList = stringList.map { observer?.id(from: $0) }
        idList = idList.filter { $0 != nil }
        caseList = idList.map { OpinionData($0!) }
        print(caseList!)
        citeTable.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.getCaseListData()
        }

    }
    
    // Get title, citation, etc. for cases in table
    func getCaseListData() {
        guard let list = caseList else {
            print("No citing cases")
            return
        }
        for (index, element) in list.enumerated() {
            getData(index, element)
        }
    }
    
    // Get case title to display in table
    func getData(_ i: Int, _ element: OpinionData) {
        // TBA
        let ep = "/opinions/\(element.id)/"
        let dataObserver = DataObserver(ep)
        dataObserver.controller = self
        dataObservers.append(dataObserver)
        dataObserver.load()
    }
    
    
    // MARK: - Table View
    
    // Return number of sections in table
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Return number of items in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return caseList != nil ? caseList!.count : 0

    }
    
    // Get cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CaseCell", for: indexPath)
        //  TBA: Get cases from courtlistener
        let caseLaw = caseList![indexPath.row]
        cell.textLabel!.text = caseLaw.description
        return cell
    }
    
    // MARK: - Segues
    // Segue to detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "citeDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                // Get object to be viewed
                let object = caseList![indexPath.row]
                // Format detail view
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
//                controller.caseId = object.id
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

}
