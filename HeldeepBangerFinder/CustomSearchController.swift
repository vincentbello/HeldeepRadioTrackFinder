//
//  CustomSearchController
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 6/16/15.
//  Copyright (c) 2015 Vincent Bello. All rights reserved.
//

import UIKit

class CustomSearchController: UISearchController, UISearchBarDelegate {
    
    lazy var _searchBar: CustomSearchBar = {[unowned self] in
        let result = CustomSearchBar(frame: CGRectZero)
        result.delegate = self
        return result
    }()
    
    override var searchBar: UISearchBar {
        get {
            return _searchBar
        }
    }
    
    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        self.customInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
    }
    
    func customInit() {
        hidesNavigationBarDuringPresentation = false
        dimsBackgroundDuringPresentation = false
        
        searchBar.searchBarStyle = .Minimal
        searchBar.textField?.textColor = UIColor.whiteColor()
        searchBar.placeholder = "Search Heldeep Radio Tracks"
    }
}


class CustomSearchBar: UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        setShowsCancelButton(false, animated: false)
    }
}