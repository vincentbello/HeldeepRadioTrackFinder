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
    
    func configureFor(episode: Episode, isNew: Bool = false) {
        
//        titleLabel.text = episode.formattedTitle()
        titleLabel.text = episode.title
        subtitleLabel.text = "\(episode.formattedDate()) · \(episode.durationInMinutes())"
        
        numberLabel.text = String(episode.epId)
        
        layoutMargins = UIEdgeInsetsZero
        
//        // If a new episode just came out, give it a [NEW] badge
//        if isNew {
//            self.addNewBadge()
//        } else {
//            self.accessoryView = nil
//            self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
//        }
    }
    
    
}