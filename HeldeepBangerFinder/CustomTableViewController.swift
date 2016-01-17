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
    
    var loadingView: LoadingView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell
        tableView.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: GlobalConstants.TableViewCell.Identifier)
        
        // Set UI navigation bar properties
        navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        navigationController?.navigationBar.frame.origin.y = -15
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "left")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "left")
        let imageView = UIImageView(image: UIImage(named: "full_logo.png"))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        let titleView = UIView(frame: CGRectMake(0, 0, 128, 30))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        
        navigationItem.title = " "
        
        navigationItem.titleView = titleView
        navigationItem.titleView!.alpha = 0
        
        // Set section index properties
        tableView.separatorColor = UIColor(white: 0.33, alpha: 1.0)
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        tableView.sectionIndexTrackingBackgroundColor = UIColor.darkGrayColor()
        tableView.sectionIndexColor = UIColor.groupTableViewBackgroundColor()
        
        tableView.backgroundColor = UIColor.darkGrayColor()
        
        loadingView = LoadingView(frame: tableView.bounds)
        
    }
    
    func showLoadingView() {
        tableView.scrollEnabled = false
        tableView.addSubview(loadingView!)
    }
    
    func removeLoadingView() {
        tableView.scrollEnabled = true
        loadingView!.removeFromSuperview()
    }
}