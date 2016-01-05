//
//  NowPlayingButton.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/27/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit

class NowPlayingButton: UIButton {
    
    var playingLabel: UILabel?
    var forwardIcon: UIImageView?

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        forwardIcon = UIImageView(frame: CGRectMake(45, 3, 20, 20))
        forwardIcon!.image = UIImage(named: "forward")
        
        playingLabel = UILabel()
        playingLabel!.text = "Now\nPlaying"
        playingLabel!.textColor = UIColor.whiteColor()
        playingLabel!.font = UIFont.systemFontOfSize(11)
        playingLabel!.numberOfLines = 2
        playingLabel!.textAlignment = .Center
        playingLabel!.sizeToFit()
        playingLabel!.frame.size.width = 45
        
        addSubview(forwardIcon!)
        addSubview(playingLabel!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                playingLabel!.textColor = UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.0)
            } else {
                playingLabel!.textColor = UIColor.whiteColor()
            }
        }
    }

}
