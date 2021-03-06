//
//  Extensions.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 6/11/15.
//  Copyright (c) 2015 Vincent Bello. All rights reserved.
//
//  Extensions to common types

import UIKit
import MediaPlayer

extension String {
    
    // Check if self contains string s. Returns true/false
    func contains(s: String) -> Bool {
        return (self.rangeOfString(s) != nil) ? true : false
    }
    
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    // Split self by regular expression splitter. Returns array of split string
    func split(splitter: String) -> [String] {
        let regEx = try? NSRegularExpression(pattern: splitter, options: [])
        let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
        let modifiedString = regEx!.stringByReplacingMatchesInString(self, options: NSMatchingOptions(),range: NSMakeRange(0, self.characters.count),withTemplate:stop)
        let arr = modifiedString.componentsSeparatedByString(stop)
        return arr
    }
    
    // Returns the index of string target in self
    func indexOf(target: String) -> Int {
        let range = self.lowercaseString.rangeOfString(target)
        if let range = range {
            return self.startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
    
    // Finds string needle in self and returns a NSMutableAttributedString where needle is bolded
    func findAndBold(needle: String) -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString(string: self)
        // find range of needle
        let index = self.indexOf(needle)
        if index > -1 {
            let boldFont = UIFont.boldSystemFontOfSize(GlobalConstants.Fonts.SubtitleSize)
            let range = NSRange(location: index, length: needle.characters.count)
            
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.groupTableViewBackgroundColor(), range: NSRange(location: 0, length: index))
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: range)
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.groupTableViewBackgroundColor(), range: NSRange(location: index + needle.characters.count, length: self.characters.count - index - needle.characters.count))
            mutableString.addAttribute(NSFontAttributeName, value: boldFont, range: range)
        }
        return mutableString
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func urlEncode() -> String {
        
        let characters = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        
        characters.removeCharactersInString("&")
        
        guard let encodedString = self.stringByAddingPercentEncodingWithAllowedCharacters(characters) else {
            return self
        }
        
        return encodedString
        
    }

}

extension Array {
    // Check if self contains an element. Returns true/false
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

extension UISearchBar {
    
    // Adds a UISearchBar's text field as an attribute by finding it among its subviews
    var textField: UITextField? {
        for parent in subviews {
            for subview in parent.subviews {
                if let textField = subview as? UITextField {
                    return textField
                }
            }
        }
        return nil
    }
}

extension UITableView {
    
    // Allows to reload all sections with animation
    func reloadAllSections() {
        self.reloadData()
        let range = NSMakeRange(0, self.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
        self.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    
    
}

extension UIApplication {
    // Attempt to open first functioning URL in array
    class func tryURL(urls: [String]) {
        let application = UIApplication.sharedApplication()
        for url in urls {
            let urlObj = NSURL(string: url)!
            if application.canOpenURL(urlObj) {
                application.openURL(urlObj)
                return
            }
        }
    }
    
    class func toggleActivityIndicator(enabled: Bool) {
        sharedApplication().networkActivityIndicatorVisible = enabled
    }
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.Top:
            border.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), thickness)
            break
        case UIRectEdge.Bottom:
            border.frame = CGRectMake(0, CGRectGetHeight(self.frame) - thickness, CGRectGetWidth(self.frame), thickness)
            break
        case UIRectEdge.Left:
            border.frame = CGRectMake(0, 0, thickness, CGRectGetHeight(self.frame))
            break
        case UIRectEdge.Right:
            border.frame = CGRectMake(CGRectGetWidth(self.frame) - thickness, 0, thickness, CGRectGetHeight(self.frame))
            break
        default:
            break
        }
        
        border.backgroundColor = color.CGColor
        
        self.addSublayer(border)
    }
    
    func blur(color: UIColor = UIColor.whiteColor()) {
        shadowColor = color.CGColor
        shadowOffset = CGSizeMake(0.0, 0.0)
        shadowRadius = 5.0
        shadowOpacity = 1
        masksToBounds = false
        shouldRasterize = true
    }
    
    func unblur() {
        shadowOpacity = 0
    }
    
}

extension UIView {
    // adds border to frame (for debugging)
    func addDebuggingBorder(color: UIColor = UIColor.redColor()) {
        self.layer.borderWidth = 1
        self.layer.borderColor = color.CGColor
    }
    
    // Rotate infinitely
    func rotate() {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(double: M_PI * 2)
        rotation.duration = 2
        rotation.cumulative = true
        rotation.repeatCount = FLT_MAX
        self.layer.addAnimation(rotation, forKey: "rotationAnimation")
    }
    
    // Pulse infinitely
    func pulse() {
        let pulseAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.5
        pulseAnimation.fromValue = 0.7
        pulseAnimation.toValue = 1.3
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = FLT_MAX
        self.layer.addAnimation(pulseAnimation, forKey: nil)
    }
}

extension UILabel {
    // animate to color
    func animateToColor(color: UIColor, duration: Double = 0.2) {
        UIView.animateWithDuration(duration) {_ in
            self.textColor = color
        }
    }
}

extension MPNowPlayingInfoCenter {
    // Update key value pair
    func updateInfo(pairs: Dictionary<String, AnyObject>) {
        var info: Dictionary? = nowPlayingInfo
        if (info != nil) {
            for (k, v) in pairs {
                info![k] = v
            }
            nowPlayingInfo = info!
        } else {
            nowPlayingInfo = pairs
        }
    }
}