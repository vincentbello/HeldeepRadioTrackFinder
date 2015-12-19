//
//  Extensions.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 6/11/15.
//  Copyright (c) 2015 Vincent Bello. All rights reserved.
//
//  Extensions to common types

import UIKit

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
    
}