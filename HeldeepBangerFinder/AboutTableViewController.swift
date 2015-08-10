//
//  AboutTableViewController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 6/10/15.
//  Copyright (c) 2015 Vincent Bello. All rights reserved.
//
//  Controller for embedded tableView with static cells

import UIKit

class AboutTableViewController: UITableViewController {

    // MARK: Properties
    
    @IBOutlet weak var createdCell: UITableViewCell!
    @IBOutlet weak var durationCell: UITableViewCell!
    @IBOutlet weak var downloadCell: UITableViewCell!
    @IBOutlet weak var listenCell: UITableViewCell!

    var currentEpisode: Episode!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createdCell.detailTextLabel?.text = currentEpisode.formattedDate()
        durationCell.detailTextLabel?.text = currentEpisode.durationInSeconds()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = self.tableView.cellForRowAtIndexPath(indexPath)
        
        if selectedCell == downloadCell {
            // Download: go to iTunes page
            UIApplication.tryURL([GlobalConstants.ItunesLink, "https://itunes.apple.com/us/podcast/heldeep-radio/id887878735?mt=2"])
        } else if selectedCell == listenCell {
            // Listen: go to SoundCloud app
            UIApplication.tryURL(["soundcloud://tracks:\(currentEpisode.id)", currentEpisode.permalink_url, "http://www.soundcloud.com"])
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
