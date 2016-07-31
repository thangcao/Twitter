//
//  ProfileUserViewController.swift
//  Twitter
//
//  Created by Cao Thắng on 7/30/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit



class ProfileUserViewController: BaseViewMenuController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var indexPathForCell: NSIndexPath?
    var user: User?
    var tweets: [Tweet]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initTableView()
        if user == nil {
            user = User._currentUser
        }
        
        TwitterClient.sharedInstance.userTimeLine(User._currentUser!, success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
        }) { (NSError) in
        }
    }
    
    @IBAction func onMenuAction(sender: UIBarButtonItem) {
        menuDelegate?.callSlideMenuDelegate(true)
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
    // Number of sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    // Number of cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if tweets != nil {
                return (tweets?.count)!
            }
            return 0
        default:
            return 0
        }
    }
    // Cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("UserHeaderCell") as! UserHeaderCell
            cell.user = self.user
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case 1:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
            cell.tweet = tweets![indexPath.row]
            return cell
        default:
            return UITableViewCell()
        }
    }
}
