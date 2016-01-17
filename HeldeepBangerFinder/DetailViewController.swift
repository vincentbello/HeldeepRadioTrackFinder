//
//  DetailViewController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/18/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit
import Parse

class DetailViewController: UIViewController, CurrentTrackDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var tracksHeaderLabel: UILabel!
    
    @IBOutlet weak var trackTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var playerView: PlayerView!
    
    let episode: Episode
    
    let tracksTableViewController = TracksTableViewController()
    
    var isPlaying: Bool = false
    var currentTrackIndex: Int?
    
    @IBAction func onListenTapped(sender: AnyObject) {
        // Listen: go to SoundCloud app
        UIApplication.tryURL(["soundcloud://tracks:\(episode.scId)", episode.permalinkUrl, "http://www.soundcloud.com"])
    }
    
    @IBAction func onDownloadTapped(sender: AnyObject) {
        let nativeUrl = "itms://itunes.apple.com/us/podcast/heldeep-radio/id887878735?mt=2"
        let browserUrl = "https://itunes.apple.com/us/podcast/heldeep-radio/id887878735?mt=2"
        
        UIApplication.tryURL([nativeUrl, browserUrl])
    }
    
    init(episode: Episode, isPlaying: Bool = false) {
        self.episode = episode
        super.init(nibName: "DetailViewController", bundle: nil)
        
        navigationItem.titleView = TitleLabel(labelText: episode.formattedTitle())
        
        if (isPlaying) {
            self.isPlaying = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.text = episode.title
        dateLabel.text = episode.formattedDate()
        durationLabel.text = episode.durationInMinutes()
        
        playerView.configureFor(episode, currentlyPlaying: self.isPlaying)
        
        trackTableView.delegate = tracksTableViewController
        trackTableView.dataSource = tracksTableViewController
        // Load the NIB files
        let nib = UINib(nibName: "TrackViewCell", bundle: nil)
        // Register this NIB, which contains the cell
        trackTableView.registerNib(nib, forCellReuseIdentifier: "TrackViewCell")
        trackTableView.layoutMargins = UIEdgeInsetsZero
        
        fetchTracks()
        
        // Set up view re-rendering notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "renderViewAnimations", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Done in viewDidAppear because UI update needs view
        if (self.isPlaying) {
            playerView.configureProgressBar()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        appDelegate().nowPlayingId = playerView.isPlaying ? episode.objectId! : nil
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
                    let tracks = objects! as! [Track]
                    self.tracksTableViewController.tracks = tracks
                    self.playerView.tracks = tracks
                    self.playerView.delegate = self
                    self.tracksTableViewController.playerView = self.playerView
                    
                    dispatch_async(dispatch_get_main_queue()) {_ in
                        self.updateTracksHeader()
                        self.trackTableView.reloadData()
                        self.loadingView.removeFromSuperview()
                        
                        if (self.episode.selectedTrack != nil) {
                            let idx = self.tracksTableViewController.tracks.indexOf({ $0.objectId == self.episode.selectedTrack?.objectId })
                            if (idx != nil) {
                                self.tracksTableViewController.selectSpecificTrack(idx!)
                            }
                        }
                    }
                    
                    
                    
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
    
    func updateCurrentTrack(index: Int?) {
        // Update current track
        self.tracksTableViewController.currentTrackIndex = index
        trackTableView.reloadData()
    }
    
    func updateTrackCells() {
        trackTableView.reloadData()
    }
    
    func renderViewAnimations() {
        if (playerView.isPlaying) {
            trackTableView.reloadData()
        }
    }
}
