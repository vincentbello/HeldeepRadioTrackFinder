//
//  ActionButton.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/19/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit

class ActionButton: UIButton {

    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                backgroundColor = UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.0)
            } else {
                backgroundColor = UIColor.clearColor()
            }
        }
    }
}
