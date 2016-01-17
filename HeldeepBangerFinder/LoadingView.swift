//
//  LoadingView.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 1/8/16.
//  Copyright © 2016 Vincent Bello. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    init(frame: CGRect, message: String = "Loading episodes...") {
        super.init(frame: frame)
        
        backgroundColor = GlobalConstants.Colors.Background
        
        let label = UILabel()
        label.text = message
        label.textColor = UIColor.lightTextColor()
        label.font = UIFont.systemFontOfSize(15)
        label.sizeToFit()
        label.center = CGPointMake(center.x, center.y - 50)
        
        layer.zPosition++
        
        addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
