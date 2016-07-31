//
//  ProfileUserViewController.swift
//  Twitter
//
//  Created by Cao Thắng on 7/30/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit



class ProfileUserViewController: BaseViewMenuController {
    
    let offsetHeaderViewStopTranformations :CGFloat = 40.0
    let distanceHeaderBotAndUserNameLabel: CGFloat = 35.0
    let offsetNameLabelBelowHeaderView: CGFloat = 95.0
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet var headerBackgroundImageView:UIImageView!
    @IBOutlet var headerBackgroundBlurImageView:UIImageView!
    
    @IBOutlet weak var headerNameLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var idName: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var isCurrentUser: Bool = true
    var indexPathForCell: NSIndexPath?
    var user: User?
    var tweets: [Tweet]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initTableView()
        if user == nil {
            user = User._currentUser
            isCurrentUser = true
        } else {
            logoutButton.hidden = true
            isCurrentUser = false
            menuBarButton.image = UIImage()
            menuBarButton.title = "Back"
        }
        
        initOpacityBarView()
        initAndLoadDataViewForUser()
        
        loadDataFromAPI(user!)
    }
    override func viewDidAppear(animated: Bool) {
        initHeaderView()
    }
    @IBAction func onMenuAction(sender: UIBarButtonItem) {
        if isCurrentUser {
            menuDelegate?.callSlideMenuDelegate(true)
        } else {
            dismissViewControllerAnimated(true, completion:nil)
        }
    }
    
    @IBAction func logoutAction(sender: UIButton) {
        TwitterClient.sharedInstance.logout()
    }
    
    // MARK: - Navigation
    
    //      In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //      Get the new view controller using segue.destinationViewController.
        //      Pass the selected object to the new view controller.
        let navigationController = segue.destinationViewController as! UINavigationController
        if navigationController.topViewController is DetailViewController {
            if segue.identifier == "userCellSegue" {
                let detailViewController = navigationController.topViewController as! DetailViewController
                let cell = sender as! UITableViewCell
                if let indexPath = tableView.indexPathForCell(cell) {
                    detailViewController.delegate = self
                    indexPathForCell = indexPath
                    detailViewController.detailTweet = self.tweets![indexPath.row]
                }
                
            }
        }
    }
    
}

// InitView
extension ProfileUserViewController {
    func initTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.clearColor()
    }
    func initOpacityBarView(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }
    
    func initAndLoadDataViewForUser(){
        profileImage.setImageWithURL((user?.profileUrl)!)
        profileImage.layer.cornerRadius = 5
        profileImage.clipsToBounds = true
        profileImage.layer.borderColor = UIColor.whiteColor().CGColor
        profileImage.layer.borderWidth = 2
        userName.text = user?.name!
        idName.text = "@\((user?.screenName)!)"
        followerCountLabel.text = "\((user?.followerCount)!)"
        followingCountLabel.text = "\((user?.followingCount)!)"
        tweetCountLabel.text = "\((user?.retweetCount)!) Tweet"
        headerNameLabel.text = user?.name!
        logoutButton.layer.cornerRadius = 5
        logoutButton.clipsToBounds = true
        logoutButton.layer.borderColor = UIColor.blueColor().CGColor
        logoutButton.layer.borderWidth = 1
    }
    func initHeaderView(){
        
        // Init Background View
        headerBackgroundImageView = UIImageView(frame: headerView.bounds)
        headerBackgroundBlurImageView = UIImageView(frame: headerView.bounds)
        // Blur Image
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = headerBackgroundBlurImageView.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        headerBackgroundBlurImageView.addSubview(blurEffectView)
        headerBackgroundBlurImageView?.alpha = 0.0
        if user?.profileBackGroundUrl != "" {
            let backgroundURl = NSURL(string: (user?.profileBackGroundUrl)!)
            headerBackgroundImageView.setImageWithURL(backgroundURl!)
            headerBackgroundBlurImageView.setImageWithURL(backgroundURl!)
        } else {
            headerBackgroundImageView?.image = UIImage(named: "iron_man")
            headerBackgroundBlurImageView?.image = UIImage(named: "iron_man")
        }
        headerBackgroundImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        headerBackgroundBlurImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        // Should add background view below SubView
        headerView.insertSubview(headerBackgroundImageView, belowSubview: headerNameLabel)
        headerView.insertSubview(headerBackgroundBlurImageView, belowSubview: headerNameLabel)
        headerView.clipsToBounds = true
    }
}
// Detailview delegate
extension ProfileUserViewController : DetailViewControllerDelegate {
    func detailViewDelegate(detailViewController: DetailViewController, updateTweet: Tweet, replyTweet: Tweet?) {
        // Update Tweet Cell
        let cell = self.tableView.cellForRowAtIndexPath(indexPathForCell!) as! TweetCell
        cell.updateTweetForReTweetAndFavorite(updateTweet)
        // Add Reply Tweet
        if let replyTweet = replyTweet {
            addNewTweet(replyTweet)
        }
    }
    func addNewTweet(newTweet: Tweet) {
        tweets!.insert(newTweet, atIndex: 0)
        tableView.reloadData()
        // TableView Scroll to the top
        tableView.setContentOffset(CGPointZero, animated:true)
    }
    
}
// TableView
extension ProfileUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets != nil {
            return (tweets?.count)!
        }
        return 0
    }
    // Cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
        cell.tweet = tweets![indexPath.row]
        return cell
    }
}
// Load Data From User Timeline
extension ProfileUserViewController {
    func loadDataFromAPI(user: User){
        TwitterClient.sharedInstance.userTimeLine(user, success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
        }) { (NSError) in
        }
    }
}
// Update header view when is scrolling
extension ProfileUserViewController {
    func updateHeaderView(offSetScrollView: CGFloat) {
        var profileImageTransform = CATransform3DIdentity
        var headerViewTransform = CATransform3DIdentity
        // SrollView Pull Down
        if offSetScrollView < 0 {
            let headerViewScaleFactor :CGFloat = -(offSetScrollView) / headerView.bounds.height
            let headerViewSize = ((headerView.bounds.height * (1.0 + headerViewScaleFactor)) - headerView.bounds.height)/2.0
            // 3D Translate
            headerViewTransform = CATransform3DTranslate(headerViewTransform, 0, headerViewSize, 0)
            headerViewTransform = CATransform3DScale(headerViewTransform, 1.0 + headerViewScaleFactor, 1.0 + headerViewScaleFactor, 0)
            // Blur effect
            headerBackgroundBlurImageView?.alpha = min(1.0, (-offSetScrollView)/(headerView.bounds.height/4))
            headerView.layer.transform = headerViewTransform
            
        } else {  // Scroll To UP OR Down
            
            // 3D Translate View
            headerViewTransform = CATransform3DTranslate(headerViewTransform, 0, max(-offsetHeaderViewStopTranformations, -offSetScrollView), 0)
            let labelNameTransform = CATransform3DMakeTranslation(0, max(-distanceHeaderBotAndUserNameLabel, offsetNameLabelBelowHeaderView - offSetScrollView), 0)
            let labelTweetTransform = CATransform3DMakeTranslation(0, max(-distanceHeaderBotAndUserNameLabel + 1, offsetNameLabelBelowHeaderView - offSetScrollView + 1), 0)
            headerNameLabel.layer.transform = labelNameTransform
            tweetCountLabel.layer.transform = labelTweetTransform
            // Blur Image
            headerBackgroundBlurImageView?.alpha = min (1.0, (offSetScrollView - offsetNameLabelBelowHeaderView)/distanceHeaderBotAndUserNameLabel)
            
            // Scale profile imageView with slow animation
            let profileScaleFactor = (min(offsetHeaderViewStopTranformations, offSetScrollView)) / profileImage.bounds.height / 1.4
            
            let profileSize = ((profileImage.bounds.height * (1.0 + profileScaleFactor)) - profileImage.bounds.height) / 2.0
            profileImageTransform = CATransform3DTranslate(profileImageTransform, 0, profileSize, 0)
            profileImageTransform = CATransform3DScale(profileImageTransform, 1.0 - profileScaleFactor, 1.0 - profileScaleFactor, 0)
            
            // Set Higher priority for Profile Image and Header View
            if offSetScrollView <= offsetHeaderViewStopTranformations {
                
                // Scroll Down profileView should have the priority higher than headerView
                if profileImage.layer.zPosition < headerView.layer.zPosition{
                    headerView.layer.zPosition = 0
                }
                
            }else {
                //Scroll Up profileView should have the priority lower than headerView
                if profileImage.layer.zPosition >= headerView.layer.zPosition{
                    headerView.layer.zPosition = 1
                }
            }
        }
        headerView.layer.transform = headerViewTransform
        profileImage.layer.transform = profileImageTransform
    }
    
}
extension ProfileUserViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView(scrollView.contentOffset.y)
    }
}
