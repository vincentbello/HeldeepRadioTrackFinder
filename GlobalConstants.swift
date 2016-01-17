//
//  GlobalConstants.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 6/9/15.
//  Copyright (c) 2015 Vincent Bello. All rights reserved.
//
//  Helper class with helpful constants

//import Foundation
import UIKit

struct GlobalConstants {
    
    static let StoryboardName = "Main"
    
    static let DefaultRowHeight = CGFloat(44)
    
    static let EpisodeHeaders = ["Heldeep Radio Cooldown", "Heldeep Cooldown", "Heldeep Radio Classic", "Heldeep Classic", "Heldeep Radio Halfbeat", "Heldeep Halfbeat", "Guestmix by Sander van Doorn"]

    static let ItunesLink = "itms://itunes.apple.com/us/podcast/heldeep-radio-051/id887878735?i=342917449&mt=2"
    
    struct SoundCloud {
        static let ClientID = "20c0a4e42940721a64391ac4814cc8c7"
        static let FetchTracksURL = "https://api.soundcloud.com/users/heldeepradio/tracks.json?limit=200&client_id=\(ClientID)"
    }
    
    struct Date {
        static let Formatter = NSDateFormatter()
        static let InputFormat = "y/MM/dd HH:mm:ss xx"
        static let OutputFormat = "LLL d, y"
    }
    
    struct Colors {
        static let Navigation = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0.5)
        static let CellBackground = UIColor(red: 43/255, green: 43/255, blue: 43/255, alpha: 1.0)
        static let Type = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0)
        static let Background = UIColor(white: 0.27, alpha: 1)
        static let SoundCloud = UIColor(red: 1.0, green: 97/255, blue: 0, alpha: 1.0)
    }
    
    struct Fonts {
        static let SubtitleSize = CGFloat(12.0)
    }
    
    struct TableViewCell {
        static let Identifier = "EpisodeCell"
    }
    
}