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
                UIView.animateWithDuration(0.2) {_ in
                    self.layer.backgroundColor = UIColor(white: 0.75, alpha: 1.0).CGColor
                }
            } else {
                layer.backgroundColor = UIColor.clearColor().CGColor
            }
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            print("did set background color")
        }
    }
}
