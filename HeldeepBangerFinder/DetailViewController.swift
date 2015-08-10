//
//  DetailViewController.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 6/10/15.
//  Copyright (c) 2015 Vincent Bello. All rights reserved.
//
//  Controller for episode detail view

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var streamWebView: UIWebView!
    @IBOutlet weak var tracklistTextView: UITextView!
    
    var currentEpisode: Episode!

    // Creates instance for episode
    class func forEpisode(episode: Episode) -> DetailViewController {
        let storyboard = UIStoryboard(name: GlobalConstants.StoryboardName, bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        viewController.currentEpisode = episode
        
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
        let label = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width - 50, 44))
            label.backgroundColor = UIColor.clearColor()
            label.numberOfLines = 2
            label.font = UIFont(name: GlobalConstants.Fonts.Main.Bold, size: 17.0)
            label.textAlignment = NSTextAlignment.Center
            label.text = currentEpisode.formattedTitle()
            label.textColor = UIColor.whiteColor()
        
        self.navigationItem.titleView = label
        
        tracklistTextView.text = currentEpisode.descr

        
        // Embed in UIWebView
        
        let embedURL = "https://w.soundcloud.com/player/?url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F\(currentEpisode.id)&color=ff6600&auto_play=false&show_artwork=false&amp;sharing=false"
        let embedObject = NSURL(string: embedURL)
        let requestObj = NSURLRequest(URL: embedObject!)
        streamWebView.loadRequest(requestObj)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // Segue to embedded "about" view controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if let aboutScene = segue.destinationViewController as? AboutTableViewController {
            aboutScene.currentEpisode = currentEpisode
        }
    }
}