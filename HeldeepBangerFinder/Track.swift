//
//  Track.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/18/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import Parse


class Track : PFObject, PFSubclassing {
    
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
        return "Track"
    }
    
    // MARK: - Parse Core Properties
    
    @NSManaged var displayName: String?
    
    @NSManaged var episode: Episode
    @NSManaged var title: String
    @NSManaged var type: String
    
    
    func typeIcon() -> UIImage? {
        switch self.type {
        case "Heldeep Radio Cooldown", "Heldeep Cooldown":
            return UIImage(named: "cooldown")
        case "Heldeep Radio Classic", "Heldeep Classic":
            return UIImage(named: "classic")
        case "Heldeep Halfbeat", "Heldeep Radio Halfbeat":
            return UIImage(named: "halfbeat")
        default:
            return nil
        }
    }
    
}






















