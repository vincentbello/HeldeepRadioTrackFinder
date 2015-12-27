//
//  Episode.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 6/9/15.
//  Copyright (c) 2015 Vincent Bello. All rights reserved.
//
//  This class defines a Heldeep Radio episode.

//import UIKit
//
//class Episode: NSObject {
//    
//    let properties = ["id", "ep_id", "title", "descr", "created_at", "duration", "purchase_url", "stream_url", "permalink_url"]
//    
//    var id : Int = 0
//    var ep_id : Int = 0
//    var title : String = ""
//    var descr : String = ""
//    var created_at : String = ""
//    var duration : Int = 0
//    var purchase_url : String = ""
//    var stream_url : String = ""
//    var permalink_url : String = ""
//    var trackArray = [String]()
//    var favorite = false
//    
//    // Initialize Episode object from JSON information
//    init(JSONDictionary: NSDictionary) {
//        super.init()
//        
//        for (key, value) in JSONDictionary {
//            
//            var keyName = key as! String
//            keyName = keyName == "description" ? "descr" : keyName
//            if self.properties.contains(keyName) {
//                if let _ = value as? String {
//                    self.setValue(String(value as! NSString), forKey: keyName)
//                } else if let _ = value as? Int {
//                    self.setValue(Int(value as! Int), forKey: keyName)
//                }
//            }
//        }
//        
//        self.parseTracks()
//    }
//
//    func formattedId() -> String {
//        return "#" + String(format: "%03d", self.ep_id)
//    }
//    
//    // Parse episode description into track array. Parses out the episode headers, like "Heldeep Classic."
//    func parseTracks() {
//        self.trackArray = self.descr.split("(\\n)+[0-9]{1,2}[.)] ")
//        self.trackArray.removeAtIndex(0)
//        if self.trackArray.count > 0 {
//            for index in 0...self.trackArray.count - 1 {
//                for header in GlobalConstants.EpisodeHeaders {
//                    self.trackArray[index] = self.trackArray[index].replace(header, withString: "")
//                }
//                
//            }
//        }
//        
//    }
//}

import Parse


class Episode : PFObject, PFSubclassing {
    
    // MARK: - PFSubclassing
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Episode"
    }
    
    // MARK: - Parse Core Properties
    
    @NSManaged var displayName: String?
    
    @NSManaged var epId: Int
    @NSManaged var title: String
    @NSManaged var duration: Int
    @NSManaged var scCreatedAt: String
    @NSManaged var scId: Int
    @NSManaged var permalinkUrl: String
    @NSManaged var streamUrl: String
    
    // Formats episode title
    func formattedTitle() -> String {
        return self.title.stringByReplacingOccurrencesOfString("Oliver Heldens - ", withString: "")
    }
    
    // Gets duration of episode in format "H h M min"
    func durationInMinutes() -> String {
        var x = self.duration / 60000
        let minutes = x % 60
        x /= 60
        let hours = x % 24
        return hours == 0 ? "\(minutes) min" : "\(hours) hr \(minutes) min"
    }
    
    // Gets duration of episode in format "H:M:S"
    func durationInSeconds() -> String {
        var x = self.duration / 1000
        let seconds = x % 60
        x /= 60
        let minutes = x % 60
        x /= 60
        let hours = x % 24
        let minutesStr = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let secondsStr = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        return (hours == 0 ? "" : "\(hours):") + "\(minutesStr):\(secondsStr)"
    }
    
    // Formats date string into a defined format
    func formattedDate() -> String {
        let inputFormatter = GlobalConstants.Date.Formatter
        inputFormatter.dateFormat = GlobalConstants.Date.InputFormat
        let date = inputFormatter.dateFromString(self.scCreatedAt)
        let outputFormatter = GlobalConstants.Date.Formatter
        outputFormatter.dateFormat = GlobalConstants.Date.OutputFormat
        return outputFormatter.stringFromDate(date!)
    }
    
    // Gives you the formatted URL
    func audioUrl() -> String {
        return "\(self.streamUrl)?client_id=\(GlobalConstants.SoundCloud.ClientID)"
    }
}





















