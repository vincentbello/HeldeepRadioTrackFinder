//
//  CustomSearchController
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 6/16/15.
//  Copyright (c) 2015 Vincent Bello. All rights reserved.
//

import UIKit

class CustomSearchController: UISearchController {

    override init(searchResultsController: UIViewController!) {
        super.init(searchResultsController: searchResultsController)
        
        // Set basic searchbar properties
        self.searchBar.sizeToFit()
        self.searchBar.barStyle = UIBarStyle.Black
        self.searchBar.tintColor = UIColor.whiteColor()
        self.searchBar.placeholder = "Search Heldeep Radio Tracks"
        self.searchBar.textField?.textColor = UIColor.whiteColor()
    }
    
    required init(coder aDecoder: NSCoder) {
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

}
