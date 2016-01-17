//
//  TypeListViewCell.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/22/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit

class TypeListViewCell: UITableViewCell {

    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutMargins = UIEdgeInsetsZero
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
