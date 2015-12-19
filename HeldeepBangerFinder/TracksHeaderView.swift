//
//  TracksHeaderView.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/18/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit

class TracksHeaderView: UIView {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        
        layer.addBorder(UIRectEdge.Top, color: UIColor(red:0.33, green:0.33, blue:0.33, alpha:1.0), thickness: 1.0)
        layer.addBorder(UIRectEdge.Bottom, color: UIColor(red:0.47, green:0.47, blue:0.47, alpha:1.0), thickness: 2.0)
        backgroundColor = UIColor.clearColor()
    }

}
