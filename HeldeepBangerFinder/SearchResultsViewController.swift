//
//  SearchResultsViewController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 1/7/16.
//  Copyright © 2016 Vincent Bello. All rights reserved.
//

import UIKit

protocol ResignSearchBarDelegate: class {
    func resignSearchBar()
}

class SearchResultsViewController: SearchBaseViewController, UISearchResultsUpdating {
    
    weak var delegate: ResignSearchBarDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UITapGestureRecognizer(target: self, action: "resign")
        recognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(recognizer)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard searchController.active else { return }
        
        searchString = searchController.searchBar.text
    }
    
    func resign() {
        delegate?.resignSearchBar()
    }
}
