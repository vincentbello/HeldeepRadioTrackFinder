//
//  EpisodesTableViewController.swift
//  
//
//  Created by Vincent Bello on 6/9/15.
//
//

import Foundation
import UIKit

import Parse

class EpisodesTableViewController: CustomTableViewController, NowPlayingDelegate {
    
    // MARK: - Properties
    
    var episodes = [Episode]()
    
    // Search-related controller properties
    var searchController: CustomSearchController!
    
    // Refresh-related properties
    var refreshLoadingView: UIView!
    var ollie: UIImageView!
    var isRefreshAnimating = false
    var isRefreshHeadRotated = false
    
    // Star animation-related properties
    var animationArray = [UIImage]()
    var imageIndex = 0
    var favoritedRow = 0
    
    var nowPlayingId: String?
    
    // Cast collection view
    var castCollectionView: UICollectionView?
    
    
    @IBAction func searchBegin(sender: AnyObject) {
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the NIB file
        let nib = UINib(nibName: "EpisodeViewCell", bundle: nil)
        // Register this NIB, which contains the cell
        tableView.registerNib(nib,
            forCellReuseIdentifier: "EpisodeViewCell")
        
//        resultsTableController = ResultsTableController()
        
        // We want to be the delegate for our filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
//        resultsTableController.tableView.delegate = self
        
        // Set up searchController
        searchController = CustomSearchController()
        tableView.tableHeaderView = searchController.searchBar
        
        // Allow access to other views (i.e. detail view) from any cells, even in the results controller
        definesPresentationContext = true
        
        self.setUpRefreshControl()
        self.setUpLoadingIndicator()
        
        self.getEpisodes()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("episodes view will appear")
    }
    
    func isNowPlaying(playingId: String) {
        print("is now playing")
        nowPlayingId = playingId
        let nowPlayingButton = UIButton(type: .Custom)
        nowPlayingButton.frame = CGRectMake(0, 0, 60, 25)
        let forwardIcon = UIImageView(frame: CGRectMake(40, 3, 20, 20))
        forwardIcon.image = UIImage(named: "forward")
        nowPlayingButton.addSubview(forwardIcon)
        let playingLabel = UILabel(frame: CGRectMake(0, 0, 35, 25))
        playingLabel.text = "Playing"
        playingLabel.textColor = UIColor.whiteColor()
        playingLabel.font = UIFont.systemFontOfSize(12)
        playingLabel.sizeToFit()
        playingLabel.frame.origin = CGPointMake(0, 4)
        nowPlayingButton.addSubview(playingLabel)
        nowPlayingButton.addTarget(self, action: "goToNowPlaying", forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nowPlayingButton)
        print("newly set ID: \(self.nowPlayingId)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Fetches episode data asynchronously from SoundCloud API. Populates episode data and reloads tableView
    func getEpisodes() {
        
        if Reachability.isConnectedToNetwork() {
            // Connected to a network
            let query = PFQuery(className: Episode.parseClassName())
            query.orderByDescending("epId")
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    // Found episodes
                    self.episodes = objects! as! [Episode]
                    self.tableView.reloadData()
                    
                } else {
                    print("Error!")
                }
                
                self.tableView.userInteractionEnabled = true
            }
        
        
        } else {
            // Not connected to the network
            self.showError("No Internet connection.")
            self.tableView.userInteractionEnabled = true
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        if self.refreshControl!.refreshing {
            self.refreshControl!.endRefreshing()
        }
    }
    
    // Show easily dismissible error banner when no data can be loaded
    func showError(message: String) {
        
        let alertFrameY = self.navigationController?.navigationBar.frame.height
        let alertFrame = CGRectMake(0, alertFrameY!, self.tableView.bounds.width, GlobalConstants.DefaultRowHeight)
        let alertView = UIView(frame: alertFrame)
        
        let alertLabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.width, GlobalConstants.DefaultRowHeight))
            alertLabel.text = message
            alertLabel.textColor = UIColor.whiteColor()
            alertLabel.textAlignment = NSTextAlignment.Center
            alertLabel.font = UIFont.boldSystemFontOfSize(14.0)
            alertLabel.backgroundColor = UIColor.redColor()
        
        alertView.addSubview(alertLabel)
        
        let buttonX = self.tableView.bounds.width - GlobalConstants.DefaultRowHeight
        let dismissButton = UIButton(type: UIButtonType.System)
            dismissButton.frame = CGRectMake(buttonX, 0, GlobalConstants.DefaultRowHeight, GlobalConstants.DefaultRowHeight)
        
        let dismissButtonImage = UIImageView(frame: CGRectMake(GlobalConstants.DefaultRowHeight/4, GlobalConstants.DefaultRowHeight/4, GlobalConstants.DefaultRowHeight/2, GlobalConstants.DefaultRowHeight/2))
            dismissButtonImage.image = UIImage(named: "dismiss.png")
            dismissButtonImage.tintColor = UIColor.whiteColor()
        
        dismissButton.addSubview(dismissButtonImage)
        dismissButton.addTarget(self, action: "dismissError:", forControlEvents: UIControlEvents.TouchUpInside)
        
        alertView.addSubview(dismissButton)
        self.tableView.addSubview(alertView)
    
    }
    
    // Dismiss error banner
    func dismissError(sender: UIButton!) {
        let alertView = sender.superview
        UIView.animateWithDuration(0.2, animations: {
            alertView!.alpha = 0.0
            }, completion: { finished in
                alertView!.removeFromSuperview()
        })
        
    }
    
    // Set up the custom refresh control
    func setUpRefreshControl() {
        
        self.refreshControl = UIRefreshControl()
        self.refreshLoadingView = UIView(frame: self.refreshControl!.bounds)
        self.refreshLoadingView.backgroundColor = UIColor.clearColor()
        
        // Create the graphic image view
        ollie = UIImageView(image: UIImage(named: "ollie.png"))
        
        let midX = self.tableView.frame.size.width / 2.0
        let center = CGPoint(x: midX, y: self.ollie.center.y)
        ollie.center = center
        
        // Add the graphics to the loading view
        self.refreshLoadingView.addSubview(self.ollie)
        
        // Clip so the graphics don't stick out
        self.refreshLoadingView.clipsToBounds = true;
        
        // Hide the original spinner icon
        self.refreshControl!.tintColor = UIColor.clearColor()
        
        // Add the loading view to our refresh control
        self.refreshControl!.addSubview(self.refreshLoadingView)
        
        // Initialize flags
        self.isRefreshHeadRotated = false;
        self.isRefreshAnimating = false;
        
        // When activated, invoke refresh function
        self.refreshControl?.addTarget(self, action: "getEpisodes", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // When scrolling (up), animate the refresh control
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        // get the current size of the refresh controller
        var refreshBounds = self.refreshControl!.bounds
        
        // distance the table has been pulled >= 0
        let pullDistance = max(0.0, -self.refreshControl!.frame.origin.y)
        
        // Calculate the pull ratio, between 0.0-1.0
        let pullRatio = min( max(pullDistance, 0.0), 100.0) / 100.0;

        if pullRatio == 0.0 || pullRatio == 1.0 {
            self.ollie.transform = CGAffineTransformMakeRotation(0.0)
            self.isRefreshHeadRotated = pullRatio == 0.0 ? false : true
        } else if self.isRefreshHeadRotated {
            self.isRefreshHeadRotated = false
        }

        if !self.isRefreshHeadRotated {
            // Rotate head
            let maxRadians = CGFloat(2 * M_PI)
            let ollieRadians = pullRatio * maxRadians
            self.ollie.transform = CGAffineTransformMakeRotation(ollieRadians)
        }
        
        // Set the encompassing view's frames
        refreshBounds.size.height = pullDistance;
        
        self.refreshLoadingView.frame = refreshBounds;
        
        // If we're refreshing and the animation is not playing, then play the animation
        if (self.refreshControl!.refreshing && !self.isRefreshAnimating) {
            self.animateRefreshView()
        }
    }
    
    // Animate refresh control
    func animateRefreshView() {

        // Flag that we are animating
        self.isRefreshAnimating = true;
        
        UIView.animateWithDuration(Double(0.2), delay: Double(0.0), options: UIViewAnimationOptions.CurveLinear, animations: {
            
                // rotate the spinner by M_PI = PI = 180 degrees
                self.ollie.transform = CGAffineTransformRotate(self.ollie.transform, CGFloat(M_PI))
            
            }, completion: { finished in
                // if still refreshing, keep spinning, else reset
                if (self.refreshControl!.refreshing) {
                    self.animateRefreshView()
                } else {
                    self.resetAnimation()
                }
        })
    }
    
    // Finish refresh animation
    func resetAnimation() {
        // Reset our flags and }background color
        self.isRefreshAnimating = false;
        self.isRefreshHeadRotated = false
    }
    
    func setUpLoadingIndicator() {
        
        let tblViewFooter = UIView(frame: CGRectZero)
        
        let loadingLabel = UILabel()
            loadingLabel.text = "Loading episodes..."
            loadingLabel.textColor = UIColor.lightTextColor()
            loadingLabel.font = UIFont.boldSystemFontOfSize(15)
        
        tblViewFooter.addSubview(loadingLabel)
        
        loadingLabel.sizeToFit()
        
        let offsetY = (self.navigationController?.navigationBar)!.frame.height + self.searchController.searchBar.frame.height
        loadingLabel.center = CGPointMake(self.tableView.center.x, self.tableView.center.y - offsetY)
        
        self.tableView.tableFooterView = tblViewFooter
        
        self.tableView.userInteractionEnabled = false
        
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        return episodes.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        let episode = episodes[index]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("EpisodeViewCell", forIndexPath: indexPath) as! EpisodeViewCell
        
        cell.configureFor(episode, isNew: index == 0)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedEpisode = episodes[indexPath.row]
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        showDetail(selectedEpisode)
    }
    
    func showDetail(episode: Episode) {
        let dvc = DetailViewController(episode: episode, isPlaying: self.nowPlayingId == episode.objectId)
        dvc.delegate = self
        showViewController(dvc, sender: self)
    }
    
    func goToNowPlaying() {
        let episode = episodes.filter({ $0.objectId == self.nowPlayingId! }).first!
        showDetail(episode)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    //  MARK: - Other functions
}