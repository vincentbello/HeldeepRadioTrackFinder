//
//  CustomSearchController
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 6/16/15.
//  Copyright (c) 2015 Vincent Bello. All rights reserved.
//

import UIKit

class CustomSearchController: UISearchController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    var defaultSearchView: DefaultSearchView?
    
    init() {
        let resultsController = ResultsTableController()
        resultsController.tableView.delegate = resultsController
        
        super.init(searchResultsController: resultsController)
        
        self.searchResultsUpdater = self
        
        delegate = self
        searchBar.delegate = self
        
        // Set basic searchbar properties
        self.searchBar.sizeToFit()
        self.searchBar.barStyle = UIBarStyle.Black
        self.searchBar.tintColor = UIColor.whiteColor()
        self.searchBar.placeholder = "Search Heldeep Radio Tracks"
        self.searchBar.textField?.textColor = UIColor.whiteColor()
        
        self.dimsBackgroundDuringPresentation = false
        
        let frameHeight = view.frame.height - searchBar.frame.height - 20
        let frameY = searchBar.frame.height + 20
        let defaultSearchFrame = CGRectMake(0, frameY, self.view.frame.width, frameHeight)
        
        defaultSearchView = DefaultSearchView(frame: defaultSearchFrame)
        self.view.addSubview(defaultSearchView!)
        defaultSearchView!.hidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        defaultSearchView!.hidden = false
        print("aksjdvn")
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        defaultSearchView!.hidden = true
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchText = searchBar.text!
        if (searchText.characters.count > 0) {
            defaultSearchView!.hidden = true
            
            self.filterContentForSearchText(searchText)
//            self.resultsTableController.tableView.reloadData()
        } else {
            defaultSearchView!.hidden = false
        }
    }
    
    func filterContentForSearchText(searchBarText: String) {
    }
}
