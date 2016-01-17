//
//  TrackResultCell.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/22/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit

class TrackResultCell: UITableViewCell {
    
    @IBOutlet weak var episodeNumberView: UIView!
    @IBOutlet weak var episodeNumberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
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
        
        clipsToBounds = true
        layoutMargins = UIEdgeInsetsZero
        episodeNumberView.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func configureFor(track: Track, canSelect: Bool = true) {
        titleLabel.text = track.title
        episodeNumberLabel.text = String(track.episode.epId)
        
        if canSelect {
            accessoryType = .DisclosureIndicator
        } else {
            accessoryType = .None
        }
    }
    
}
