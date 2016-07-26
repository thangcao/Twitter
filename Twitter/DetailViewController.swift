//
//  DetailViewController.swift
//  Twitter
//
//  Created by Cao Thắng on 7/25/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit
@objc protocol DetailViewControllerDelegate {
     func detailViewDelegate(detailViewController: DetailViewController,  updateTweet: Tweet, replyTweet: Tweet?)
}
class DetailViewController: UIViewController {
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var viewIcon: UIView!
    @IBOutlet weak var viewCount: UIView!
    @IBOutlet weak var constraintsHeightImageView: NSLayoutConstraint!
    
    @IBOutlet weak var constrainBottomViewFooter: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageView: CircleImageView!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    
    @IBOutlet weak var tweetImageView: UIImageView!
    
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    @IBOutlet weak var viewFooter: UIView!
    
    @IBOutlet weak var buttonRetweet: UIButton!
    @IBOutlet weak var buttonHeart: UIButton!
    
    @IBOutlet weak var limtLabel: UILabel!
    
    @IBOutlet weak var tweetButton: UIButton!
    
    @IBOutlet weak var messageTextView: UITextView!
    var limitMessage = 140
    
    var detailTweet: Tweet?
    var isReplyClick: Bool = false
    var beginMessage: String = ""
    weak var delegate: DetailViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadDataForViews()
        initKeyBoardAndTextView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(sender: AnyObject) {
        if let tweet = detailTweet {
            self.delegate?.detailViewDelegate(self, updateTweet: tweet, replyTweet: nil)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelKeyBoard(sender: AnyObject) {
        if isReplyClick {
            messageTextView.resignFirstResponder()
            viewFooter.hidden = true
            messageTextView.hidden = true
            viewCount.hidden = false
            tweetImageView.hidden = false
            descriptionLabel.hidden = false
            isReplyClick = false
            cancelBarButton.title = ""
        }
        
    }
    @IBAction func favoriteAction(sender: AnyObject) {
        if (detailTweet?.isFavorited)! {
            TwitterClient.sharedInstance.unFavoriteTweet((detailTweet?.id)!, success: { (response) in
                if response != nil {
                    print("UnFavorite Successfull")
                }
                }, failure: {(error) in
                    
            })
            self.detailTweet?.favoriteCount -= 1
            self.favoriteCountLabel.text =  "\((self.detailTweet?.favoriteCount)!)"
            self.detailTweet?.isFavorited = false
            self.updateFavoriteView((self.detailTweet?.isFavorited)!)
        } else {
            TwitterClient.sharedInstance.favoriteTweet((detailTweet?.id)!, success: { (response) in
                if response != nil {
                    print("Favorite Successfull")
                    
                }
                }, failure: {(error) in
                    
            })
            self.detailTweet?.favoriteCount += 1
            self.favoriteCountLabel.text =  "\((self.detailTweet?.favoriteCount)!)"
            self.detailTweet?.isFavorited = true
            self.updateFavoriteView((self.detailTweet?.isFavorited)!)
        }
    }
    
    @IBAction func retweetAction(sender: AnyObject) {
        if (detailTweet?.isRetweeted)! {
            TwitterClient.sharedInstance.getRetweetedId((detailTweet?.id)!, success: { (retweetetId) in
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
            self.detailTweet?.retweetCount -= 1
            self.retweetCountLabel.text =  "\((self.detailTweet?.retweetCount)!)"
            self.detailTweet?.isRetweeted = false
            self.updateReTweetView((self.detailTweet?.isRetweeted)!)
        } else {
            TwitterClient.sharedInstance.reTweet((detailTweet?.id)!, success: { (response) in
                if response != nil {
                    print("Retweet Successfull")
                    
                }
                }, failure: {(error) in
                    
            })
            self.detailTweet?.retweetCount += 1
            self.retweetCountLabel.text =  "\((self.detailTweet?.retweetCount)!)"
            self.detailTweet?.isRetweeted = true
            self.updateReTweetView((self.detailTweet?.isRetweeted)!)
        }
        
    }
    
    @IBAction func replyAction(sender: AnyObject) {
        if !isReplyClick {
            viewFooter.hidden = false
            messageTextView.hidden = false
            viewCount.hidden = true
            tweetImageView.hidden = true
            descriptionLabel.hidden = true
            messageTextView.becomeFirstResponder()
            isReplyClick = true
            cancelBarButton.title = "Cancel"
        }
    }
    @IBAction func tweetAction(sender: AnyObject) {
        TwitterClient.sharedInstance.replyTweet(messageTextView.text, originalId: (detailTweet?.id)!, success: { (tweet) in
            let newTweet = tweet
            if let newTweet = newTweet {
                self.delegate?.detailViewDelegate(self, updateTweet: self.detailTweet!,replyTweet: newTweet)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }) { (error) in
            print(error)
        }
    }
}
// Init & Update Views
extension DetailViewController {
    func loadDataForViews() {
        if detailTweet != nil {
            cancelBarButton.title = ""
            usernameLabel.text = (detailTweet?.user?.name)!
            screenNameLabel.text = (detailTweet?.user?.screenName)!
            profileImageView.setImageWithURL((detailTweet?.user?.profileUrl)!)
            descriptionLabel.text = (detailTweet?.text)!
            retweetCountLabel.text = "\((detailTweet?.retweetCount)!)"
            favoriteCountLabel.text = "\((detailTweet?.favoriteCount)!)"
            createdAtLabel.text =  FortmartDateUtil.formatDateToLongDate((detailTweet?.timestamp)!)
            updateFavoriteView((detailTweet?.isFavorited)!)
            updateReTweetView((detailTweet?.isRetweeted)!)
            if detailTweet?.imageUrlString != "" {
                constraintsHeightImageView.constant = 160
                tweetImageView.hidden = false
                tweetImageView.setImageWithURL(NSURL(string: (detailTweet?.imageUrlString)!)!)
            } else {
                constraintsHeightImageView.constant = 0
                tweetImageView.hidden = true
            }
            beginMessage = "@\((detailTweet?.user?.screenName)!)" + " "
            messageTextView.text = beginMessage
            limitMessage = limitMessage - beginMessage.characters.count
            limtLabel.text = "\(limitMessage)"
            viewFooter.hidden = true
            messageTextView.hidden = true
        }
    }
    func updateFavoriteView(isFavorited: Bool){
        var image : UIImage?
        if isFavorited {
            favoriteCountLabel.textColor = UIColor.redColor()
            image = UIImage(named: "heart_red")
            
        } else {
            favoriteCountLabel.textColor = UIColor.blackColor()
            image = UIImage(named: "heart")
        }
        self.buttonHeart.alpha = 0.0
        buttonHeart.setImage(image, forState: .Normal)
        UIView.animateWithDuration(0.7, animations: { () -> Void in
            self.buttonHeart.alpha = 1.0
        })
    }
    func updateReTweetView(isReTweet: Bool) {
        var image: UIImage?
        if isReTweet {
            retweetCountLabel.textColor = UIColor.greenColor()
            image = UIImage(named: "retweet_hover")
            image = image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            buttonRetweet.tintColor = UIColor.greenColor()
            
        } else {
            retweetCountLabel.textColor = UIColor.blackColor()
            image = UIImage(named: "retweet")
        }
        self.buttonRetweet.alpha = 0.0
        buttonRetweet.setImage(image, forState: .Normal)
        UIView.animateWithDuration(0.7, animations: { () -> Void in
            self.buttonRetweet.alpha = 1.0
        })
    }
    func initKeyBoardAndTextView() {
        messageTextView.delegate = self
        messageTextView.textColor = UIColor.grayColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.keyboardWasShown(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.keyboardWasHiden(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
}
// TextView
extension DetailViewController : UITextViewDelegate{
    func textViewDidChange(textView: UITextView) {
        // Place holder for message is what is happenning
        if (messageTextView.text != WHAT_IS_HAPPENING){
            limitMessage = 140 - (messageTextView.text.characters.count)
        } else {
            limitMessage = 140
        }
        limtLabel.text = "\(limitMessage)"
        HandleUtil.trimWhiteSpace(messageTextView.text)
        if HandleUtil.trimWhiteSpace(messageTextView.text).characters.count > beginMessage.characters.count{
            tweetButton.alpha = 1
            tweetButton.userInteractionEnabled = true
        } else {
            tweetButton.alpha = 0.1
            tweetButton.userInteractionEnabled = false
        }
    }
}
// KeyBoard
extension DetailViewController {
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.constrainBottomViewFooter.constant = keyboardFrame.size.height
    }
    
    func keyboardWasHiden(notification: NSNotification) {
        self.constrainBottomViewFooter.constant = 0
    }
}