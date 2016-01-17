//
//  TypeTracksTableViewController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/22/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit
import Parse

class TypeTracksTableViewController: UITableViewController {
    
    var tracks: [Track] = [Track]()
    var type: (String, String)?
    
    init(type: (String, String)) {
        self.type = type
        
        super.init(nibName: "TypeTracksTableViewController", bundle: nil)

        let (short, long) = type
        
        let titleLabel = UILabel()
        titleLabel.attributedText = leftIconRightText(UIImage(named: short)!, color: UIColor.whiteColor(), text: long)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = " "
        
        let nib = UINib(nibName: "TrackResultCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "TrackResultCell")
        
        tableView.separatorColor = UIColor(white: 0.33, alpha: 1.0)
        
        setUpLoadingIndicator()
        
        fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchData() {
        
        let query = PFQuery.orQueryWithSubqueries(typeQueries())
        query.includeKey("episode")
        query.orderByAscending("title")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                // Found episodes
                self.tracks = objects! as! [Track]
                self.tableView.tableFooterView = nil
                self.tableView.reloadData()
                
            } else {
                print("Error!")
            }
            
            self.tableView.userInteractionEnabled = true
        }
    }
    
    func typeQueries() -> [PFQuery] {
        let (short, _) = type!
        
        var queries = [PFQuery]()
        let q1 = PFQuery(className: Track.parseClassName())
        let q2 = PFQuery(className: Track.parseClassName())
        
        switch short {
        case "classic":
            q1.whereKey("type", equalTo: "Heldeep Classic")
            q2.whereKey("type", equalTo: "Heldeep Radio Classic")
        case "cooldown":
            q1.whereKey("type", equalTo: "Heldeep Cooldown")
            q2.whereKey("type", equalTo: "Heldeep Radio Cooldown")
        case "halfbeat":
            q1.whereKey("type", equalTo: "Heldeep Halfbeat")
            q2.whereKey("type", equalTo: "Heldeep Radio Halfbeat")
            
        default:
            break
        }

        queries.append(q1)
        queries.append(q2)
        
        return queries
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TrackResultCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("TrackResultCell", forIndexPath: indexPath) as! TrackResultCell
        
        let track = tracks[indexPath.row]
        
        cell.configureFor(track)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let track = tracks[indexPath.row]
        let episode = track.episode
        episode.selectedTrack = track
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let dvc = DetailViewController(episode: episode)

        showViewController(dvc, sender: self)
    }
    
    func setUpLoadingIndicator() {
        
        let tblViewFooter = UIView(frame: view.bounds)
        
        let loadingLabel = UILabel()
        loadingLabel.text = "Loading tracks..."
        loadingLabel.textColor = UIColor.lightTextColor()
        loadingLabel.font = UIFont.boldSystemFontOfSize(15)
        loadingLabel.sizeToFit()
        print("center: \(tableView.frame)")
        let frameBounds = UIScreen.mainScreen().bounds
        loadingLabel.center = CGPointMake(frameBounds.width / 2, frameBounds.height / 2 - 50)
        tblViewFooter.addSubview(loadingLabel)
        
        self.tableView.userInteractionEnabled = false
        self.tableView.tableFooterView = tblViewFooter
        
        
    }
    
}
