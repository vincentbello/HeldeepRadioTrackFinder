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
    @IBOutlet weak var typeLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    @IBAction func searchOnSoundCloud(sender: AnyObject) {
        let encodedSearchTerm = track!.title.urlEncode()
        let searchUrl = "https://soundcloud.com/search?q=\(encodedSearchTerm)"
        UIApplication.tryURL([searchUrl])
    }
    
    @IBAction func skipToTimestamp(sender: AnyObject) {
        playerView!.goToTimestamp(Double(track!.timestamp), shouldPlay: true)
    }
    
    var track: Track?
    var playerView: PlayerView?
    
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
        
        searchButton.setAttributedTitle(leftIconRightText(UIImage(named: "soundcloud_orange")!, color: GlobalConstants.Colors.SoundCloud, text: "Search on SoundCloud"), forState: .Normal)
        
        skipButton.setAttributedTitle(leftIconRightText(UIImage(named: "play")!, color: UIColor.whiteColor(), text: "Skip to track"), forState: .Normal)
    }
    
    func configureFor(track: Track, isSelected: Bool, playerView: PlayerView) {
        self.track = track
        if (self.playerView == nil) {
            self.playerView = playerView
        }
        
        numberLabel.text = String(track.order)
        
        if (isSelected) {
            expandedTitleLabel.text = track.title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            detailView.hidden = true
            expandedDetailView.hidden = false
            if (track.type.characters.count > 0) {
                typeLabel.attributedText = track.attributedType()
                typeLabel.hidden = false
                typeLabelHeightConstraint.constant = 16
            } else {
                typeLabel.hidden = true
                typeLabelHeightConstraint.constant = 4
            }
            if (track.timestamp > 0) {
                skipButton.hidden = false
            } else {
                skipButton.hidden = true
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
