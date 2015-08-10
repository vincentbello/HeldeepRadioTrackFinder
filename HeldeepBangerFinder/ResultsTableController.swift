//
//  ResultsTableController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 6/11/15.
//  Copyright (c) 2015 Vincent Bello. All rights reserved.
//
//  Controller for search results

import UIKit

class ResultsTableController: CustomTableViewController {
    
    // MARK: Properties
    
    var searchedEpisodes = [Episode]()
    var searchText : String?
    var matchingTracks = [String]()
    
    // MARK: View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        return searchedEpisodes.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let plural = searchedEpisodes.count == 1 ? "" : "s"
        return "Found in \(searchedEpisodes.count) episode\(plural)"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let episode = searchedEpisodes[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(GlobalConstants.TableViewCell.Identifier) as! CustomTableViewCell
        
        let matchingTrack = matchingTracks[indexPath.row]

        // Configure the cell
        cell.textLabel?.text = episode.formattedTitle()
        cell.detailTextLabel?.attributedText = matchingTrack.findAndBold(searchText!)
        cell.imageView!.image = episode.favorite ? UIImage(named: "star_filled.png") : UIImage(named: "star.png")
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

        if indexPath.row == searchedEpisodes.count - 1 {
            cell.zeroInsets = true
        }
        
        
        return cell
    }
    
    
}
