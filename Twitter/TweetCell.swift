//
//  TweetCell.swift
//  Twitter
//
//  Created by Cao Thắng on 7/24/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var constraintsHeightImageView: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var idUserNameLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var tweetImageView: UIImageView!
    
    @IBOutlet weak var reTweetLabel: UILabel!
    @IBOutlet weak var retweetImageView: UIImageView!
    
    @IBOutlet weak var favotiteLabel: UILabel!
    
    @IBOutlet weak var favoriteImageView: UIImageView!
    
    @IBOutlet weak var viewFavorite: UIView!
    
    @IBOutlet weak var viewReTweet: UIView!
    
    @IBOutlet weak var viewReply: UIView!
    
    var viewController: UIViewController?
    
    var countOfFavorite: Int = 0
    var tweet : Tweet? {
        didSet {
            userName.text = tweet?.user?.name
            idUserNameLabel.text = "@\((tweet?.user?.screenName)!)"
            timestampLabel.text =  FortmartDateUtil.formatDateToShortDate((tweet?.timestamp)!)
            descriptionLabel.text = tweet?.text
            userImageView.setImageWithURL((tweet?.user?.profileUrl)!)
            favotiteLabel.text =  "\((tweet?.favoriteCount)!)"
            reTweetLabel.text =  "\((tweet?.retweetCount)!)"
            updateFavoriteView((tweet?.isFavorited)!)
            updateReTweetView((tweet?.isRetweeted)!)
            if tweet?.imageUrlString != "" {
                constraintsHeightImageView.constant = 160
                tweetImageView.hidden = false
                let imageRequest = NSURLRequest(URL: NSURL(string: (tweet?.imageUrlString)!)!)
                tweetImageView.setImageWithURLRequest(
                    imageRequest,
                    placeholderImage: nil,
                    success: { (imageRequest, imageResponse, image) -> Void in
                        
                        // imageResponse will be nil if the image is cached
                        if imageResponse != nil {
                            print("Image was NOT cached, fade in image")
                            self.tweetImageView.alpha = 0.0
                            self.tweetImageView.image = image
                            UIView.animateWithDuration(0.7, animations: { () -> Void in
                                self.tweetImageView.alpha = 1.0
                            })
                        } else {
                            print("Image was cached so just update the image")
                            self.tweetImageView.image = image
                        }
                    },
                    failure: { (imageRequest, imageResponse, error) -> Void in
                        // do something for the failure condition
                })
            } else {
                constraintsHeightImageView.constant = 0
                tweetImageView.hidden = true
            }
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initActionForViewFavorite()
        initActionForViewReTweet()
        initActionForProfileImageView()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func onReplyAction(sender: AnyObject) {
        print("Sender TweetsCell")
    }
}
// Handle Actions of View
extension TweetCell {
    func viewFavoriteAction (sender: AnyObject){
        if (tweet?.isFavorited)! {
            TwitterClient.sharedInstance.unFavoriteTweet((tweet?.id)!, success: { (response) in
                if response != nil {
                    print("UnFavorite Successfull")
                }
                }, failure: {(error) in
                    
            })
            self.tweet?.favoriteCount -= 1
            self.favotiteLabel.text =  "\((self.tweet?.favoriteCount)!)"
            self.tweet?.isFavorited = false
            self.updateFavoriteView((self.tweet?.isFavorited)!)
        } else {
            TwitterClient.sharedInstance.favoriteTweet((tweet?.id)!, success: { (response) in
                if response != nil {
                    print("Favorite Successfull")
                    
                }
                }, failure: {(error) in
                    
            })
            self.tweet?.favoriteCount += 1
            self.favotiteLabel.text =  "\((self.tweet?.favoriteCount)!)"
            self.tweet?.isFavorited = true
            self.updateFavoriteView((self.tweet?.isFavorited)!)
        }
        
    }
    func viewReTweetAction(sender: AnyObject){
        if (tweet?.isRetweeted)! {
            TwitterClient.sharedInstance.getRetweetedId((tweet?.id)!, success: { (retweetetId) in
                if let retweetetId = retweetetId {
                    TwitterClient.sharedInstance.unReTweet(retweetetId as! NSNumber, success: { (response) in
                        if response != nil {
                            print("UnRetweet Successfull")
                        }
                        }, failure: {(error) in
                            print(error)
                    })
                }
                }, failure: {(error) in
                    print(error)
            })
            
            self.tweet?.retweetCount -= 1
            self.reTweetLabel.text =  "\((self.tweet?.retweetCount)!)"
            self.tweet?.isRetweeted = false
            self.updateReTweetView((self.tweet?.isRetweeted)!)
        } else {
            TwitterClient.sharedInstance.reTweet((tweet?.id)!, success: { (response) in
                if response != nil {
                    print("Retweet Successfull")
                    
                }
                }, failure: {(error) in
                    
            })
            self.tweet?.retweetCount += 1
            self.reTweetLabel.text =  "\((self.tweet?.retweetCount)!)"
            self.tweet?.isRetweeted = true
            self.updateReTweetView((self.tweet?.isRetweeted)!)
        }
    }
    func userImageViewAction(sender: AnyObject){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateViewControllerWithIdentifier("ProfileUserViewController")
        self.viewController?.presentViewController(vc, animated: true, completion: nil)
        //self.viewController(vc, animated: true, completion: nil)
    }
}
// Init Actions for View
extension TweetCell {
    func initActionForViewFavorite(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(TweetCell.viewFavoriteAction(_:)))
        viewFavorite.addGestureRecognizer(gesture)
    }
    func initActionForViewReTweet(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(TweetCell.viewReTweetAction(_:)))
        viewReTweet.addGestureRecognizer(gesture)
    }
    func initActionForProfileImageView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(TweetCell.userImageViewAction(_:)))
        userImageView.addGestureRecognizer(gesture)
    }
    func updateTweetForReTweetAndFavorite(tweet: Tweet){
        self.tweet = tweet
        favotiteLabel.text =  "\((self.tweet?.favoriteCount)!)"
        reTweetLabel.text =  "\((self.tweet?.retweetCount)!)"
        updateFavoriteView((self.tweet?.isFavorited)!)
        updateReTweetView((self.tweet?.isRetweeted)!)
    }
}

// Declare function updateView
extension TweetCell {
    func updateFavoriteView(isFavorited: Bool){
        var image : UIImage?
        if isFavorited {
            favotiteLabel.textColor = UIColor.redColor()
            image = UIImage(named: "heart_red")
            
        } else {
            favotiteLabel.textColor = UIColor.blackColor()
            image = UIImage(named: "heart")
        }
        self.favoriteImageView.alpha = 0.0
        self.favoriteImageView.image = image
        UIView.animateWithDuration(0.7, animations: { () -> Void in
            self.favoriteImageView.alpha = 1.0
        })
    }
    func updateReTweetView(isReTweet: Bool) {
        var image: UIImage?
        if isReTweet {
            reTweetLabel.textColor = UIColor.greenColor()
            image = UIImage(named: "retweet_hover")
            image = image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            retweetImageView.tintColor = UIColor.greenColor()
            
        } else {
            reTweetLabel.textColor = UIColor.blackColor()
            image = UIImage(named: "retweet")
        }
        self.retweetImageView.alpha = 0.0
        self.retweetImageView.image = image
        UIView.animateWithDuration(0.7, animations: { () -> Void in
            self.retweetImageView.alpha = 1.0
        })
    }
}
