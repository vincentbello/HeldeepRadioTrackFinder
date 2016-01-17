//
//  SearchTableViewController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 1/6/16.
//  Copyright © 2016 Vincent Bello. All rights reserved.
//

import UIKit

class SearchTableViewController: SearchBaseViewController, UISearchControllerDelegate, ResignSearchBarDelegate {
        
    var searchController: UISearchController!
    
    @IBAction func dismissSearchViewController(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchResultsController = storyboard!.instantiateViewControllerWithIdentifier("SearchResultsViewController") as! SearchResultsViewController
        
        searchController = CustomSearchController(searchResultsController: searchResultsController)
        searchController.delegate = self
        searchResultsController.delegate = self
        searchController.searchResultsUpdater = searchResultsController
        
        navigationItem.titleView = searchController.searchBar
        
        let recognizer = UITapGestureRecognizer(target: self, action: "resignSearchBar")
        recognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(recognizer)
        
        definesPresentationContext = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchController.active = true
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        dispatch_async(dispatch_get_main_queue()) {_ in
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func resignSearchBar() {
        dispatch_async(dispatch_get_main_queue()) {_ in
            self.searchController.searchBar.resignFirstResponder()
        }
    }
}
