//
//  DefaultSearchView.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/22/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit

class DefaultSearchView: UIView {

    @IBOutlet weak var typeListTableView: UITableView!
    
    var navigationController: UITableViewController?
    var typeListTableViewController = TypeListTableViewController()
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        typeListTableView.sizeToFit()
        
        typeListTableView.layer.addBorder(.Top, color: UIColor(red: 0.47, green: 0.47, blue: 0.47, alpha: 1.0), thickness: 1.0)
        typeListTableView.layer.addBorder(.Bottom, color: UIColor(red: 0.47, green: 0.47, blue: 0.47, alpha: 1.0), thickness: 1.0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        let view = NSBundle.mainBundle().loadNibNamed("DefaultSearchView", owner: self, options: nil).first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        let nib = UINib(nibName: "TypeListViewCell", bundle: nil)
        typeListTableView.registerNib(nib, forCellReuseIdentifier: "TypeListViewCell")
        
        typeListTableViewController.defaultSearchView = self
        typeListTableView.delegate = typeListTableViewController
        typeListTableView.dataSource = typeListTableViewController
    }

}
