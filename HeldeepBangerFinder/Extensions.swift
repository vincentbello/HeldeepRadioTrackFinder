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
        let regEx = NSRegularExpression(pattern: splitter, options: nil, error: nil)
        let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
        let modifiedString = regEx!.stringByReplacingMatchesInString(self, options: NSMatchingOptions(),range: NSMakeRange(0, count(self)),withTemplate:stop)
        let arr = modifiedString.componentsSeparatedByString(stop)
        return arr
    }
    
    // Returns the index of string target in self
    func indexOf(target: String) -> Int {
        var range = self.lowercaseString.rangeOfString(target)
        if let range = range {
            return distance(self.startIndex, range.startIndex)
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
            let boldFont = UIFont(name: GlobalConstants.Fonts.Main.Bold, size: GlobalConstants.Fonts.SubtitleSize)
            let range = NSRange(location: index, length: count(needle))
            
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.groupTableViewBackgroundColor(), range: NSRange(location: 0, length: index))
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: range)
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.groupTableViewBackgroundColor(), range: NSRange(location: index + count(needle), length: count(self) - index - count(needle)))
            mutableString.addAttribute(NSFontAttributeName, value: boldFont!, range: range)
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
        for parent in subviews as! [UIView] {
            for subview in parent.subviews as! [UIView] {
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
        let range = NSMakeRange(0, self.numberOfSections())
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


extension UILabel {
    
    var substituteFontName : String {
        get { return self.font.fontName }
        set {
            if self.font.fontName.rangeOfString("Bold") == nil {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
    
    var substituteFontNameBold : String {
        get { return self.font.fontName }
        set {
            if self.font.fontName.rangeOfString("Bold") != nil {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
}

extension UITextField {
    
    var substituteFontName : String {
        get { return self.font.fontName }
        set {
            if self.font.fontName.rangeOfString("Bold") == nil {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
    
    var substituteFontNameBold : String {
        get { return self.font.fontName }
        set {
            if self.font.fontName.rangeOfString("Bold") != nil {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
}