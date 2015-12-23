//
//  TypeListTableViewController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/22/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit

class TypeListTableViewController: UITableViewController {
    
    let types = [
        ("classic", "Heldeep Classic"),
        ("cooldown", "Heldeep Cooldown"),
        ("halfbeat", "Heldeep Halfbeat")
    ]
    
    var defaultSearchView: DefaultSearchView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return types.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TypeListViewCell {
        let (typeShort, typeLong) = types[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TypeListViewCell", forIndexPath: indexPath) as! TypeListViewCell
        
        cell.typeLabel.text = typeLong
        cell.typeImage.image = UIImage(named: typeShort)
        
        cell.layoutMargins = UIEdgeInsetsZero

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let type = types[indexPath.row]
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        defaultSearchView!.hidden = true
        
        let tvc = TypeTracksTableViewController(type: type)
        showViewController(tvc, sender: self)
    }

}
