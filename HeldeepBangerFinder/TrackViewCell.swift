//
//  TrackViewCell.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/18/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit

class TrackViewCell: UITableViewCell {


    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var expandedDetailView: UIView!
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var trackIcon: UIImageView!
    
    @IBOutlet weak var expandedTitleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBAction func searchOnSoundCloud(sender: AnyObject) {
        let encodedSearchTerm = searchTerm!.urlEncode()
        let searchUrl = "https://soundcloud.com/search?q=\(encodedSearchTerm)"
        UIApplication.tryURL([searchUrl])
    }
    
    var searchTerm: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureFor(track: Track, isSelected: Bool) {
        numberLabel.text = String(track.order)
        
        if (isSelected) {
            expandedTitleLabel.text = track.title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            detailView.hidden = true
            expandedDetailView.hidden = false
            searchTerm = track.title
            if (track.type.characters.count > 0) {
                typeLabel.attributedText = track.attributedType()
                typeLabel.hidden = false
            } else {
                typeLabel.hidden = true
            }
        } else {
            titleLabel.text = track.title
            let icon = track.typeIcon()
            trackIcon.image = icon
            titleLabel.frame.size.width = UIScreen.mainScreen().bounds.width - (icon != nil ? 85 : 55)
            
            detailView.hidden = false
            expandedDetailView.hidden = true
            
        }
        
        layoutMargins = UIEdgeInsetsZero
    }

    
}
