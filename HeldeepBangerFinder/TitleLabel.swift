//
//  TitleLabel.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 1/8/16.
//  Copyright © 2016 Vincent Bello. All rights reserved.
//

import UIKit

class TitleLabel: UILabel {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    init(labelText: String) {
        super.init(frame: CGRectZero)
        
        let attributedString = NSMutableAttributedString(string: labelText.uppercaseString)
        let attributes = [
            NSKernAttributeName: 1.6,
            NSFontAttributeName: UIFont.systemFontOfSize(15, weight: UIFontWeightMedium),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        attributedString.addAttributes(attributes, range: NSMakeRange(0, labelText.characters.count))
        
        attributedText = attributedString
        
        sizeToFit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
