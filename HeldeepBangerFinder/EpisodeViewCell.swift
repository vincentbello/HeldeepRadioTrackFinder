//
//  EpisodeViewCell.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/18/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit

class EpisodeViewCell: UITableViewCell {

    @IBOutlet weak var numberContainer: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        numberContainer.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func configureFor(episode: Episode, isNew: Bool = false, isPlaying: Bool = false) {
        
        titleLabel.text = episode.formattedTitle()
        subtitleLabel.text = "\(episode.formattedDate()) · \(episode.durationInMinutes())"
        
        numberLabel.text = String(episode.epId)
        
        layoutMargins = UIEdgeInsetsZero
        
        let hasAccessory = isNew || isPlaying
        // Accessory type
        self.accessoryType = hasAccessory ? .None : .DisclosureIndicator
        
        // Accessory view
        if hasAccessory {
            if isPlaying {
                addPlayingIndicator()
            } else if isNew {
                addNewBadge()
            }
        } else {
            accessoryView = nil
        }
    }
    
    func addNewBadge() {
        let label = UILabel(frame: CGRectMake(0, 0, 35, 20))
        label.text = "NEW"
        label.textColor = GlobalConstants.Colors.CellBackground
        label.backgroundColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(11, weight: UIFontWeightHeavy)
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        label.textAlignment = .Center
        label.transform = CGAffineTransformMakeScale(0.4, 0.4)
        
        self.accessoryView = label
        self.accessoryType = UITableViewCellAccessoryType.None

        UIView.animateWithDuration(0.8, delay: 0,
            usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2,
            options: [], animations: {
            self.accessoryView!.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
        
    }
    
    func addPlayingIndicator() {
        accessoryView = UIImageView(image: UIImage(named: "playing")!)
        accessoryView!.rotate()
    }
    
    
}
