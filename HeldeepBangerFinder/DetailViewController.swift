//
//  DetailViewController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/18/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit
import Parse

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var tracksHeaderLabel: UILabel!
    
    @IBOutlet weak var trackTableView: UITableView!

    @IBOutlet weak var playerView: PlayerView!
    
    let episode: Episode
    
    let tracksTableViewController = TracksTableViewController()
    
    @IBAction func onListenTapped(sender: AnyObject) {
        // Listen: go to SoundCloud app
        UIApplication.tryURL(["soundcloud://tracks:\(episode.id)", episode.permalinkUrl, "http://www.soundcloud.com"])
    }
    
    @IBAction func onDownloadTapped(sender: AnyObject) {
        let nativeUrl = "itms://itunes.apple.com/us/podcast/heldeep-radio/id887878735?mt=2"
        let browserUrl = "https://itunes.apple.com/us/podcast/heldeep-radio/id887878735?mt=2"
        
        UIApplication.tryURL([nativeUrl, browserUrl])
    }
    
    init(episode: Episode) {
        self.episode = episode
        super.init(nibName: "DetailViewController", bundle: nil)
        
        navigationItem.title = episode.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.text = episode.title
        dateLabel.text = episode.formattedDate()
        durationLabel.text = episode.durationInMinutes()
        
        playerView.configureFor(episode)
        
        trackTableView.delegate = tracksTableViewController
        trackTableView.dataSource = tracksTableViewController
        // Load the NIB files
        let nib = UINib(nibName: "TrackViewCell", bundle: nil)
        // Register this NIB, which contains the cell
        trackTableView.registerNib(nib, forCellReuseIdentifier: "TrackViewCell")
        trackTableView.layoutMargins = UIEdgeInsetsZero
        
        fetchTracks()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        playerView.pause()
        playerView.reset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func fetchTracks() {
        
        if Reachability.isConnectedToNetwork() {
            let query = PFQuery(className: Track.parseClassName())
            query.whereKey("episode", equalTo: self.episode)
            query.orderByAscending("order")
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // Found tracks
                    self.tracksTableViewController.tracks = objects! as! [Track]
                    self.tracksTableViewController.playerView = self.playerView
                    self.updateTracksHeader()
                    self.trackTableView.reloadData()
                    
                    
                } else {
                    print("Error!")
                }
            }
        } else {
            print("No Internet connection")
        }
        
    }
    
    func updateTracksHeader() {
        tracksHeaderLabel.text = "Tracks (\(tracksTableViewController.tracks.count))"
    }
}
