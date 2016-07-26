//
//  UpdateTweetViewController.swift
//  Twitter
//
//  Created by Cao Thắng on 7/24/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit

@objc protocol UpdateTweetViewControllerDelegate {
    optional func updateTweetViewController(updateViewController: UpdateTweetViewController, updateTweet newTweet: Tweet)
}

class UpdateTweetViewController: UIViewController{
    
    @IBOutlet weak var avaterBar: UIBarButtonItem!
    @IBOutlet weak var heightConstraintOfViewHeader: NSLayoutConstraint!
    
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var replyLabel: UILabel!
    
    @IBOutlet weak var ReplyTextView: UITextView!
    
    @IBOutlet weak var viewFooterBottomConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var limitLabel: UILabel!
    
    @IBOutlet weak var twitterButton: UIButton!
    
    var replyTweet: Tweet?
    var limitMessage = 140
    var isReplyMessage :Bool = true
    weak var delegate: UpdateTweetViewControllerDelegate?
    var beginMessage: String = WHAT_IS_HAPPENING
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadUserForBarButton()
        initKeyBoardAndTextView()
        if isReplyMessage {
            loadDataTweetForReply()
        } else {
            setUpViewForNewTweet()
        }
        ReplyTextView.text = beginMessage
        if beginMessage != WHAT_IS_HAPPENING {
            limitMessage = limitMessage - beginMessage.characters.count
            limitLabel.text = "\(limitMessage)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closeAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func twitterAction(sender: AnyObject) {
        if isReplyMessage {
            TwitterClient.sharedInstance.replyTweet(ReplyTextView.text, originalId: (replyTweet?.id)!, success: { (tweet) in
                if let newTweet = tweet {
                    self.delegate?.updateTweetViewController!(self, updateTweet: newTweet)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }) { (error) in
                print(error)
            }
        } else {
            let text = ReplyTextView.text.stringByReplacingOccurrencesOfString("\n", withString: "\n\r")
            TwitterClient.sharedInstance.updateTweet(text, success: { (tweet) in
                if let newTweet = tweet {
                    self.delegate?.updateTweetViewController!(self, updateTweet: newTweet)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                }, failure: { (error) in
                    print(error)
            })
        }
        
    }
}
// SetUp View For Controller
extension UpdateTweetViewController {
    func loadDataTweetForReply(){
        if replyTweet != nil {
            replyLabel.text = "Reply for \((replyTweet?.user?.name)!)"
            beginMessage = "@\((replyTweet?.user?.screenName)!)" + " "
            twitterButton.alpha = 0.1
            twitterButton.userInteractionEnabled = false
            
        }
    }
    func setUpViewForNewTweet() {
        ReplyTextView.text = beginMessage
        viewHeader.hidden = true
        heightConstraintOfViewHeader.constant = 0
        twitterButton.alpha = 0.1
        twitterButton.userInteractionEnabled = false
    }
    func initKeyBoardAndTextView() {
        ReplyTextView.delegate = self
        ReplyTextView.textColor = UIColor.grayColor()
        ReplyTextView.becomeFirstResponder()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UpdateTweetViewController.keyboardWasShown(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UpdateTweetViewController.keyboardWasHiden(_:)), name:UIKeyboardWillHideNotification, object: nil)

    }
    func loadUserForBarButton(){
//        let avatar = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
//        let imageRequest = NSURLRequest(URL: (User.currentUser?.profileUrl)!)
//        avatar.setImageWithURLRequest(
//            imageRequest,
//            placeholderImage: nil,
//            success: { (imageRequest, imageResponse, image) -> Void in
//                
//                // imageResponse will be nil if the image is cached
//                if imageResponse != nil {
//                    print("Image was NOT cached image")
//                    self.avaterBar.image = image
//                } else {
//                    print("Image was cached so just update the image")
//                    self.avaterBar.image = image
//                }
//            },
//            failure: { (imageRequest, imageResponse, error) -> Void in
//                // do something for the failure condition
//        })
        avaterBar.title =  (User.currentUser?.name)!
    }
}
// KeyBoard
extension UpdateTweetViewController {
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.viewFooterBottomConstrain.constant = keyboardFrame.size.height
    }
    func keyboardWasHiden(notification: NSNotification) {
        self.viewFooterBottomConstrain.constant = 0
    }
}
// TextView Edit Change
extension UpdateTweetViewController : UITextViewDelegate{
    func textViewDidBeginEditing(textView: UITextView) {
        if !isReplyMessage {
            // Set the first selected
            ReplyTextView.selectedRange = NSMakeRange(0, 0);
        }
        
    }
    func textViewDidChange(textView: UITextView) {
        // Place holder for textView
        if beginMessage == WHAT_IS_HAPPENING && !isReplyMessage{
            var newString = ReplyTextView.text.substringFromIndex(ReplyTextView.text.startIndex)
            let index = newString.startIndex.advancedBy(1)
            newString = newString.substringToIndex(index)
            beginMessage = newString
            ReplyTextView.text = beginMessage
        } else {
            if ((ReplyTextView.text == "" || ReplyTextView.text == WHAT_IS_HAPPENING) && !isReplyMessage) {
                beginMessage = WHAT_IS_HAPPENING
                ReplyTextView.text = beginMessage
                ReplyTextView.selectedRange = NSMakeRange(0, 0);
            }
        }
        // Count text in textView Onchange
        if (ReplyTextView.text != WHAT_IS_HAPPENING){
            limitMessage = 140 - (ReplyTextView.text.characters.count)
        } else {
            limitMessage = 140
        }
      
        limitLabel.text = "\(limitMessage)"
        HandleUtil.trimWhiteSpace(ReplyTextView.text)
        if HandleUtil.trimWhiteSpace(ReplyTextView.text).characters.count > beginMessage.characters.count{
            twitterButton.alpha = 1
            twitterButton.userInteractionEnabled = true
        } else {
            twitterButton.alpha = 0.1
            twitterButton.userInteractionEnabled = false
        }
        
        
    }
}
