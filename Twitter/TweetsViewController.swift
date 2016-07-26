//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Cao Thắng on 7/23/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit
import MBProgressHUD
class TweetsViewController: UIViewController{
    var tweets: [Tweet]?
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    let limitOfData = 20
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initTableView()
        loadDataFromHomeAPI(limitOfData, maxID: nil)
        initPullToRefesh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        if navigationController.topViewController is UpdateTweetViewController {
            let updateViewController = navigationController.topViewController as! UpdateTweetViewController
            updateViewController.delegate = self
            if segue.identifier == "replySegue" {
                if let chosenTweetCell = sender!.superview!!.superview!.superview!.superview as? TweetCell{
                    let chosenTweet = chosenTweetCell.tweet
                    updateViewController.isReplyMessage = true
                    updateViewController.replyTweet = chosenTweet
                }
            } else {
                if segue.identifier == "newSegue" {
                    updateViewController.isReplyMessage = false
                }
            }
        } else {
            if navigationController.topViewController is DetailViewController {
                if segue.identifier == "cellSegue" {
                    let detailViewController = navigationController.topViewController as! DetailViewController
                    let cell = sender as! UITableViewCell
                    if let indexPath = tableView.indexPathForCell(cell) {
                        detailViewController.delegate = self
                        detailViewController.indexPath = indexPath
                        detailViewController.detailTweet = self.tweets![indexPath.row]
                    }
                    
                }
            }
        }
    }
}
// UpdateView Controller
extension TweetsViewController: UpdateTweetViewControllerDelegate{
    func updateTweetViewController(updateViewController: UpdateTweetViewController, updateTweet: Tweet) {
        addNewTweet(updateTweet)
    }
    func addNewTweet(newTweet: Tweet) {
        tweets!.insert(newTweet, atIndex: 0)
        tableView.reloadData()
        // TableView Scroll to the top
        tableView.setContentOffset(CGPointZero, animated:true)
    }
    func initPullToRefesh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: #selector(TweetsViewController.loadDataFromHomeAPI), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(refreshControl!, atIndex: 0)
    }
}
//Detail View Controller
extension TweetsViewController: DetailViewControllerDelegate {
    func detailViewController(detailViewController: DetailViewController, updateTweet: Tweet, indexPath: NSIndexPath?, replyTweet: Tweet?) {
        // Update Tweet Cell
        let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as! TweetCell
        cell.updateTweetForReTweetAndFavorite(updateTweet)
        // Add Reply Tweet
        if let replyTweet = replyTweet {
            addNewTweet(replyTweet)
        }
    }
    
}
// TableView
extension TweetsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets != nil{
            return (tweets?.count)!
        }
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
        cell.tweet = tweets![indexPath.row]
        return cell
    }
    func initTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
        infiniteScrollLoadingIndicator()
    }
}
// Load More
extension TweetsViewController{
    func infiniteScrollLoadingIndicator(){
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }
    func loadDataFromHomeAPI(count: Int, maxID: NSNumber?){
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        TwitterClient.sharedInstance.homeTimeLine(count, maxId: maxID,success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            self.isMoreDataLoading = false
            //Stop the loading indicator
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.loadingMoreView!.stopAnimating()
            
        }) { (error: NSError) in
            print(error)
        }
        
    }
}
// Scroll
extension TweetsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Handle scroll behavior here
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, 50)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                // Load More
                if tweets!.count > 0  && tweets != nil{
                    let maxID = (tweets![tweets!.count - 1].id)
                    loadDataFromHomeAPI(limitOfData, maxID: maxID)
                }
            }
        }
    }
}
