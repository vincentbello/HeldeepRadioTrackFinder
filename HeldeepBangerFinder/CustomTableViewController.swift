//
//  CustomTableViewController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 6/11/15.
//  Copyright (c) 2015 Vincent Bello. All rights reserved.
//

import UIKit
import Foundation

class CustomTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell
        self.tableView.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: GlobalConstants.TableViewCell.Identifier)
        
        // Set UI navigation bar properties
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        self.navigationController?.navigationBar.frame.origin.y = -15
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let imageView = UIImageView(image: UIImage(named: "full_logo.png"))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        let titleView = UIView(frame: CGRectMake(0, 0, 162, 30))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        
        self.navigationItem.titleView = titleView
        
        // Set section index properties
        self.tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        self.tableView.sectionIndexTrackingBackgroundColor = UIColor.darkGrayColor()
        self.tableView.sectionIndexColor = UIColor.groupTableViewBackgroundColor()
        
        self.tableView.backgroundColor = UIColor.darkGrayColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections. This will be overwritten
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section. This will be overwritten
        return 0
    }
}