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
    @NSManaged var order: Int
    @NSManaged var timestamp: Int
    
    
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
    
    func attributedType() -> NSAttributedString {
        return leftIconRightText(self.typeIcon()!, color: GlobalConstants.Colors.Type, text: " \(self.type)")
    }
    
    func skipText() -> NSAttributedString {
        let defaultAttrTitle = leftIconRightText(UIImage(named: "play")!, color: UIColor.whiteColor(), text: "Skip to track ")
        let mutableStr = NSMutableAttributedString(attributedString: defaultAttrTitle)
        let formattedTimestamp = formatToTimestamp(timestamp)
        let timestampAttrString = NSAttributedString(string: formattedTimestamp, attributes: [NSForegroundColorAttributeName: UIColor(white: 0.70, alpha: 1), NSFontAttributeName: UIFont.systemFontOfSize(11)])
        mutableStr.appendAttributedString(timestampAttrString)
        return mutableStr
    }
    
    func hasType() -> Bool {
        return self.type.characters.count > 0
    }
    
    func hasTimestamp() -> Bool {
        return self.timestamp > 0
    }
    
}






















