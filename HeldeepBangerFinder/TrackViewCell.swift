//
//  TrackViewCell.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/18/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit
import QuartzCore

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
    
    let overlay: UIVisualEffectView = UIVisualEffectView()
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        searchButton.setAttributedTitle(leftIconRightText(UIImage(named: "soundcloud_orange")!, color: GlobalConstants.Colors.SoundCloud, text: "Search on SoundCloud"), forState: .Normal)        
    }
    
    func configureFor(track: Track, isSelected: Bool, isPlaying: Bool, playerView: PlayerView) {
        self.track = track
        if (self.playerView == nil) {
            self.playerView = playerView
        }
        
        numberLabel.text = String(track.order)
        
        if (isSelected) {
            expandedTitleLabel.text = track.title
            detailView.hidden = true
            expandedDetailView.hidden = false
            if (track.hasType()) {
                typeLabel.attributedText = track.attributedType()
                typeLabel.hidden = false
                typeLabelHeightConstraint.constant = 25
            } else {
                typeLabel.hidden = true
                typeLabelHeightConstraint.constant = 4
            }
            if (track.hasTimestamp()) {
                skipButton.hidden = false
                skipButton.setAttributedTitle(track.skipText(), forState: .Normal)
            } else {
                skipButton.hidden = true
            }
        } else {
            titleLabel.text = track.title
            var icon = track.typeIcon()
            if (icon == nil && playerView.isPlaying && isPlaying) {
                icon = UIImage(named: "playing")
                trackIcon.rotate()
            }
            trackIcon.image = icon
            titleLabel.frame.size.width = UIScreen.mainScreen().bounds.width - (icon != nil ? 85 : 55)
            
            detailView.hidden = false
            expandedDetailView.hidden = true
            
            if (playerView.isPlaying && !isPlaying) {
                titleLabel.animateToColor(UIColor(white: 0.7, alpha: 1), duration: 2)
            } else {
                titleLabel.animateToColor(UIColor.whiteColor(), duration: 2)
            }
            
        }
        
        layoutMargins = UIEdgeInsetsZero
    }    
}
