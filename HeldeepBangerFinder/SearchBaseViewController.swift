//
//  SearchBaseViewController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 1/7/16.
//  Copyright © 2016 Vincent Bello. All rights reserved.
//

import UIKit
import Parse

class SearchBaseViewController: CustomTableViewController {
    
    var noTracksFoundView: NoTracksFoundView?
    
    let trackTypes = [
        ("classic", "Heldeep Classic"),
        ("cooldown", "Heldeep Cooldown"),
        ("halfbeat", "Heldeep Halfbeat")
    ]
    
    var isSearching: Bool = false
    var searchedTracks: [Track] = [Track]() {
        didSet {
            if (searchedTracks.count == 0) {
                showNoTracksView()
            } else {
                removeNoTracksView()
            }
        }
    }
    
    var searchString: String? = nil {
        didSet {
            if searchString == nil || searchString!.isEmpty {
                isSearching = false
                NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: "executeSearch", object: nil)
                tableView.reloadData()
                addHeaderView()
            } else {
                isSearching = true
                removeHeaderView()
                throttleSearch(0.3)
            }
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                removeNoTracksView()
                showLoadingView()
            } else {
                removeLoadingView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register NIBs for cells
        let nib1 = UINib(nibName: "TypeListViewCell", bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: "TypeListViewCell")
        
        let nib2 = UINib(nibName: "TrackResultCell", bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: "TrackResultCell")
        
        addHeaderView()
        
        noTracksFoundView = NoTracksFoundView(frame: tableView.bounds)
        loadingView = LoadingView(frame: tableView.bounds, message: "Finding tracks...")
        
        definesPresentationContext = true
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? searchedTracks.count : trackTypes.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !isSearching
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if isSearching {
            
            let track = searchedTracks[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("TrackResultCell", forIndexPath: indexPath) as! TrackResultCell
            
            cell.configureFor(track, canSelect: false)
            
            return cell

        } else {
            let (typeShort, typeLong) = trackTypes[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("TypeListViewCell", forIndexPath: indexPath) as! TypeListViewCell
            
            cell.typeLabel.text = typeLong
            cell.typeImage.image = UIImage(named: typeShort)
            
            return cell
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if !isSearching {
            
            let type = trackTypes[indexPath.row]
            
            let tvc = TypeTracksTableViewController(type: type)
            navigationController?.pushViewController(tvc, animated: true)

        }
    }
    
    
    // MARK: - Table header view
    
    func addHeaderView() {
        let headerFrame = CGRectMake(0, 0, tableView.frame.width, 50)
        let headerView = UIView(frame: headerFrame)
        let headerLabel = UILabel()
        headerLabel.text = "Browse Heldeep Radio Tracks"
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.font = UIFont.systemFontOfSize(17)
        headerLabel.sizeToFit()
        headerLabel.center = headerView.center
        headerView.addSubview(headerLabel)
        headerView.backgroundColor = UIColor.clearColor()
        tableView.tableHeaderView = headerView
    }
    
    func removeHeaderView() {
        tableView.tableHeaderView = nil
    }
    
    // MARK: - Search
    
    // Throttle the executeSearch function so that it waits 0.3 seconds
    // after the last key press to run
    func throttleSearch(delay: Double) {
        isLoading = true
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: "executeSearch", object: nil)
        performSelector("executeSearch", withObject: nil, afterDelay: delay)
    }
    
    // Search, then reload data
    func executeSearch() {
        
        // Fetch from Parse
        let query = PFQuery(className: Track.parseClassName())
        query.whereKey("title", matchesRegex: searchString!, modifiers: "i")
        query.includeKey("episode")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // Found episodes
                self.isLoading = false
                self.searchedTracks = objects! as! [Track]
                self.tableView.reloadData()
                
            } else {
                print("Error fetching tracks!")
            }
        }
    }
    
    func showNoTracksView() {
        tableView.scrollEnabled = false
        tableView.addSubview(noTracksFoundView!)
    }
    
    func removeNoTracksView() {
        tableView.scrollEnabled = true
        noTracksFoundView!.removeFromSuperview()
    }

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
