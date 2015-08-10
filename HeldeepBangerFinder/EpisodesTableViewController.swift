//
//  EpisodesTableViewController.swift
//  
//
//  Created by Vincent Bello on 6/9/15.
//
//

import Foundation
import UIKit

class EpisodesTableViewController: CustomTableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    // MARK: - Properties
    
    var episodes = [Episode]()
    
    var favorites = [Bool]()
    
    // Search-related controller properties
    var searchController: CustomSearchController!
    var resultsTableController: ResultsTableController!
    
    // Refresh-related properties
    var refreshLoadingView: UIView!
    var ollie: UIImageView!
    var isRefreshAnimating = false
    var isRefreshHeadRotated = false
    
    // Star animation-related properties
    var animationArray = [UIImage]()
    var imageIndex = 0
    var favoritedRow = 0
    
    // Cast collection view
    var castCollectionView: UICollectionView?
    
    
    @IBAction func searchBegin(sender: AnyObject) {
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsTableController = ResultsTableController()
        
        // We want to be the delegate for our filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        resultsTableController.tableView.delegate = self
        
        // Set up searchController
        searchController = ({
            let controller = CustomSearchController(searchResultsController: self.resultsTableController)
            controller.searchResultsUpdater = self
            
            self.tableView.tableHeaderView = controller.searchBar

            controller.delegate = self
            controller.searchBar.delegate = self    // So we can monitor text changes + others
            
            return controller
        })()
        
        // Allow access to other views (i.e. detail view) from any cells, even in the results controller
        definesPresentationContext = true
        
        self.setUpRefreshControl()
        self.setUpAnimationArray()
        self.setUpLoadingIndicator()
        
        self.getEpisodes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Save favorites into NSData before quitting
    override func viewDidDisappear(animated: Bool) {
        saveFavorites()
    }
    
    // Fetches episode data asynchronously from SoundCloud API. Populates episode data and reloads tableView
    func getEpisodes() {
        
        if Reachability.isConnectedToNetwork() {
            // Connected to a network
            
            let dataSourceURL = NSURL(string: GlobalConstants.SoundCloud.FetchTracksURL)
            let request = NSURLRequest(URL: dataSourceURL!)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
                if data != nil {
                    // Data obtained: parse JSON string
                    if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSArray {
                        
                        let episodesArray = jsonResult
                        var episodesArr = [Episode]()
                        var counter : Int = episodesArray.count
                        for ep in episodesArray {
                            let epDictionary = ep as! NSDictionary
                            let episode = Episode(JSONDictionary: epDictionary)
                            episode.ep_id = counter
                            episodesArr.append(episode)
                            counter--
                        }
                        
                        // Add the favorites if this is the first time using the app
                        if self.favorites.count == 0 {
                            self.favorites = [Bool](count: episodesArr.count, repeatedValue: false)
                        }
                        
                        let loopCount = episodesArr.count - 1
                        if (self.favorites.count < episodesArr.count) {
                            // New episode(s)
                            let epDifference = episodesArr.count - self.favorites.count
                            let missingFavorites = [Bool](count: epDifference, repeatedValue: false)
                            self.favorites = missingFavorites + self.favorites
                        }
                        
                        for index in 1...loopCount {
                            episodesArr[index].favorite = self.favorites[index]
                        }
                        
                        self.episodes = episodesArr
                        
                        self.tableView.reloadAllSections()
                    } else {
                        // Could not fetch from the SoundCloud API.
                        let message = "Could not fetch data from SoundCloud."
                        self.showError(message)
                        self.tableView.tableFooterView = nil
                    }
                    
                }
                
                if error != nil {
                    // Likely an invalid URL.
                    let message = "\(error!.localizedDescription.capitalizedString)"
                    self.showError(message)
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
        let dismissButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
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
        
//        if self.isRefreshHeadRotated && pullRatio < 1.0 {
//            self.isRefreshHeadRotated = false
//        }

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
    
    // Divide star animation sprite into UIImages and store them in property array
    func setUpAnimationArray() {
        let sprite = UIImage(named: "sprite.png")
        let spriteCG = sprite?.CGImage
        let spriteWidth = sprite?.size.width
        
        var originX = CGFloat(0)
        let imageWidth = CGFloat(100)
        let imageHeight = CGFloat(100)
        
        while (originX + imageWidth) <= spriteWidth {
            let imageArea = CGRectMake(originX, 0, imageWidth, imageHeight)
            let subImage = CGImageCreateWithImageInRect(spriteCG, imageArea)
            self.animationArray.append(UIImage(CGImage: subImage)!)
            originX += imageWidth
        }
    }
    
    func setUpLoadingIndicator() {
        
        let tblViewFooter = UIView(frame: CGRectZero)
        
        let loadingLabel = UILabel()
            loadingLabel.text = "Loading episodes..."
            loadingLabel.textColor = UIColor.lightTextColor()
            loadingLabel.font = UIFont(name: GlobalConstants.Fonts.Main.Bold, size: 15.0)
        
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
        
        return episodes.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let index = indexPath.section
        let episode = episodes[index]
        let favorite = favorites[index]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(GlobalConstants.TableViewCell.Identifier, forIndexPath: indexPath) as! CustomTableViewCell
        
        let singleTap = UITapGestureRecognizer(target: self, action: "favoriteOrUnfavorite:")
        singleTap.numberOfTapsRequired = 1
        
        // Configure the cell
        cell.textLabel?.text = episode.formattedTitle()
        cell.detailTextLabel?.textColor = UIColor.groupTableViewBackgroundColor()
        cell.detailTextLabel?.text = "\(episode.formattedDate()) · \(episode.durationInMinutes())"
        cell.imageView!.image = favorite ? self.animationArray[self.animationArray.count - 1] : self.animationArray[0]
        cell.imageView?.userInteractionEnabled = true
        cell.imageView?.tag = index
        cell.imageView?.addGestureRecognizer(singleTap)
        
        // If a new episode just came out, give it a [NEW] badge
        if index == 0 {
            cell.addNewBadge()
        } else {
            cell.accessoryView = nil
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let index = indexPath.section
        var selectedEpisode: Episode
        
        // check to see which table view cell was selected
        if tableView == self.tableView {
            selectedEpisode = episodes[index]
        } else {
            selectedEpisode = resultsTableController.searchedEpisodes[index]
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // set up the detail view controller to show
        let detailViewController = DetailViewController.forEpisode(selectedEpisode)
        self.navigationController?.pushViewController(detailViewController, animated: true)
    
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        // Section index titles
        
        var arr = [String]()
        if episodes.count > 0 {
            for ind in 0...episodes.count - 1 {
                arr.append(String(episodes.count - ind))
            }
        }
        return arr
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    //  MARK: - Other functions
    
    // Favorite or un-favorite an episode.
    func favoriteOrUnfavorite(sender: AnyObject?) {
        let section = sender?.view!!.tag
        // let episode = episodes[section!] as Episode
        favorites[section!] = !favorites[section!]
        
        if favorites[section!] {
            self.favoritedRow = section!
            NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "changeImage:", userInfo: nil, repeats: true)
        } else {
            // we have just unfavorited the row
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: section!)) as! CustomTableViewCell
            cell.imageView!.image = self.animationArray[0]
        }
        
    }
    
    // Star animation when favoriting/unfavoriting
    func changeImage(timer: NSTimer!) {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: self.favoritedRow)) as! CustomTableViewCell
        
        if (self.imageIndex < self.animationArray.count) {
            cell.imageView!.image = self.animationArray[self.imageIndex]
            self.imageIndex++
        } else {
            timer.invalidate()
            self.imageIndex = 0
        }
    }

    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if count(searchController.searchBar.text) > 0 {
            self.filterContentForSearchText(searchController.searchBar.text!)
            self.resultsTableController.tableView.reloadData()
        }
    }
    
    func filterContentForSearchText(searchBarText: String) {

        let searchText = searchBarText.lowercaseString        
        self.resultsTableController.matchingTracks = [String]()
        
        // Filter: if an episode has a track that contains searchText, display it
        self.resultsTableController.searchedEpisodes = self.episodes.filter({( episode: Episode) -> Bool in
            var match = false
            for track in episode.trackArray {
                if track.lowercaseString.rangeOfString(searchText) != nil {
                    match = true
                    self.resultsTableController.matchingTracks.append(track)
                    break
                }
            }
            
            self.resultsTableController.searchText = searchText
            
            return match
        })
        
        
    }
    
//    // Tells if today is a saturday (when new episodes come out) or not
//    func todayIsASaturday() -> Bool {
//        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
//        let components = calendar.components(.CalendarUnitWeekday, fromDate: NSDate())
//        return components.weekday == 7 ? true : false
//    }

    // Saves favorites into NSData at the end of the app life cycle
    func saveFavorites() {
        let favoritesData = NSKeyedArchiver.archivedDataWithRootObject(favorites)
        NSUserDefaults.standardUserDefaults().setObject(favoritesData, forKey: "favorites")
    }
    
}