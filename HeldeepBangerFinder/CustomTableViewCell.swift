//
//  CustomTableViewCell.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 6/11/15.
//  Copyright (c) 2015 Vincent Bello. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    var zeroInsets = false

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // Set default cell style
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set custom cell properties
        if self.zeroInsets {
            self.preservesSuperviewLayoutMargins = false
            self.separatorInset = UIEdgeInsetsZero
            self.layoutMargins = UIEdgeInsetsZero
            
        } else {
            self.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 19)
        }
        
        self.backgroundColor = GlobalConstants.Colors.Background
        
        self.textLabel?.font = UIFont.boldSystemFontOfSize(16)
        self.textLabel?.textColor = UIColor.whiteColor()
        self.textLabel?.frame.origin.x = 60
        self.detailTextLabel?.frame.origin.x = 65

        self.imageView!.frame = CGRectMake(15, 15, 30, 30)
        self.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    // Adds "NEW" badge for new Heldeep Radio episodes
    func addNewBadge() {
        
        let label = UILabel(frame: CGRectMake(0, 0, 35, 20))
            label.text = "NEW"
            label.textColor = UIColor.blackColor()
            label.backgroundColor = UIColor.whiteColor()
            label.font = UIFont.boldSystemFontOfSize(12)
            label.layer.cornerRadius = 3
            label.clipsToBounds = true
            label.textAlignment = NSTextAlignment.Center

        self.accessoryView = label
        self.accessoryType = UITableViewCellAccessoryType.None
    }

}
