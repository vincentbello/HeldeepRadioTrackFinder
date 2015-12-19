//
//  TrackViewCell.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/18/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit

class TrackViewCell: UITableViewCell {


    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureFor(track: Track, index: Int) {
        numberLabel.text = String(index)
        titleLabel.text = track.title
        
        layoutMargins = UIEdgeInsetsZero
        
//        let icon = track.typeIcon()
    }

    
}
