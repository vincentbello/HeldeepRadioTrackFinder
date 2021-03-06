//
//  TracksTableViewController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/18/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit

class TracksTableViewController: UITableViewController {
    
    var tracks = [Track]()
    var selectedIndex: Int?
    var currentTrackIndex: Int? = -1
    var playerView: PlayerView?

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let selected = indexPath.row == selectedIndex
        if selected {
            // Dynamically compute the height of the row based on its contents
            let track = tracks[indexPath.row]
            var cellHeight = track.title.heightWithConstrainedWidth(265, font: UIFont.systemFontOfSize(15, weight: UIFontWeightSemibold))
            if (track.hasType()) {
                cellHeight += 18
            }
            cellHeight += 55
            if (track.hasTimestamp()) {
                cellHeight += 35
            }
            return cellHeight
        } else {
            return 44
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TrackViewCell {
        
        let track = tracks[indexPath.row]
        // Configure the cell...
        let selected = indexPath.row == selectedIndex
        let isPlaying = indexPath.row == currentTrackIndex
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackViewCell", forIndexPath: indexPath) as! TrackViewCell
        
        cell.configureFor(track, isSelected: selected, isPlaying: isPlaying, playerView: playerView!)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var rowsToUpdate = [indexPath]
        
        if (selectedIndex == indexPath.row) {
            // deselect
            selectedIndex = nil
        } else {
            if (selectedIndex != nil) {
                rowsToUpdate.append(NSIndexPath(forRow: selectedIndex!, inSection: 0))
            }
            selectedIndex = indexPath.row
        }
        
        tableView.reloadRowsAtIndexPaths(rowsToUpdate, withRowAnimation: .Fade)
        
        if (indexPath.row == tracks.count - 1) {
            // Last row
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    func selectSpecificTrack(index: Int) {
        let idxPath = NSIndexPath(forRow: index, inSection: 0)
        tableView(tableView, didSelectRowAtIndexPath: idxPath)
        
        tableView.scrollToRowAtIndexPath(idxPath, atScrollPosition: .Bottom, animated: true)
    }
    
    func updateCurrentTrack(index: Int) {
        currentTrackIndex = index
        dispatch_async(dispatch_get_main_queue()) {_ in
            self.tableView.reloadData()
        }
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
