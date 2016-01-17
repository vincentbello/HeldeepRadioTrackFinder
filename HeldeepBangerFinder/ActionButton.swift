//
//  ActionButton.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/19/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
    
    var didSelect: Bool = false {
        didSet {
            if (didSelect) {
                UIView.animateWithDuration(0.5) {
                    self.layer.backgroundColor = UIColor.clearColor().CGColor
                }
                
            }
        }
    }

    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        layer.borderColor = UIColor.whiteColor().CGColor
        
        addTarget(self, action: "didClick", forControlEvents: .TouchUpInside)
    }
    
    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                print("highlightyboy")
                didSelect = false
                UIView.animateWithDuration(0.2) {
                    self.layer.backgroundColor = UIColor(white: 0.7, alpha: 1.0).CGColor
                }
            } else {
                if (!didSelect) {
                    print("cancelling animation")
                    layer.backgroundColor = UIColor.clearColor().CGColor
                }
//                layer.backgroundColor = UIColor(white: 0.7, alpha: 1.0).CGColor
//                UIView.animateWithDuration(0.3,
//                    animations: {
//                        self.layer.backgroundColor = UIColor.clearColor().CGColor
//                    }, completion: {_ in
//                        self.layer.backgroundColor = UIColor.clearColor().CGColor
//                })

            }
        }
    }
    
    func didClick() {
        print("selectyboy")
        didSelect = true
    }
}
