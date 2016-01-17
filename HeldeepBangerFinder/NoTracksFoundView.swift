//
//  NoTracksFoundView.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 1/8/16.
//  Copyright © 2016 Vincent Bello. All rights reserved.
//

import UIKit

class NoTracksFoundView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = GlobalConstants.Colors.Background
        
        showMessageAndIcon()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showMessageAndIcon() {
        let contentView = UIView(frame: CGRectMake(0, 0, 300, 140))
        
        let imageView = UIImageView(image: UIImage(named: "sad_face"))
        imageView.frame = CGRectMake(100, 0, 100, 100)
        let label = UILabel(frame: CGRectMake(0, 120, 300, 20))
        label.text = "Whoops! Couldn't find any tracks."
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(14)
        
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        
        addSubview(contentView)
        contentView.center = CGPointMake(center.x, center.y - 50)
    }


}
