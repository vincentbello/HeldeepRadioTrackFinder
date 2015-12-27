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

        let (_, long) = type
        navigationItem.title = long
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("view did appear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        let nib = UINib(nibName: "TrackResultCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "TrackResultCell")
        
        fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchData() {
        
        let query = PFQuery.orQueryWithSubqueries(typeQueries())
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                // Found episodes
                self.tracks = objects! as! [Track]
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
            queries.append(q1)
            queries.append(q2)
        case "cooldown":
            q1.whereKey("type", equalTo: "Heldeep Cooldown")
            q2.whereKey("type", equalTo: "Heldeep Radio Cooldown")
            queries.append(q1)
            queries.append(q2)
        case "halfbeat":
            q1.whereKey("type", equalTo: "Heldeep Halfbeat")
            q2.whereKey("type", equalTo: "Heldeep Radio Halfbeat")
            queries.append(q1)
            queries.append(q2)
        default:
            break
        }
        
        return queries
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
    
}
