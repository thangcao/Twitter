//
//  UserHeaderCellTableViewCell.swift
//  Twitter
//
//  Created by Cao Thắng on 7/30/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit

class UserHeaderCell: UITableViewCell {
    
    
    
    @IBOutlet weak var constrainsRightOfViewHeader: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageView: CircleImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var idNameLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followerCountLabel: UILabel!
    
    @IBOutlet weak var tweetCountLabel: UILabel!
    
    var user: User? {
        didSet {
            print((self.user?.name)!)
            self.self.userNameLabel.text = (self.user?.name)!
            self.idNameLabel.text = "@\((self.user?.screenName)!)"
            self.tweetCountLabel.text = "\((self.user?.retweetCount)!)"
            self.followingCountLabel.text = "\((self.user?.followingCount)!)"
            self.followerCountLabel.text =  "\((self.user?.followerCount)!)"
            self.profileImageView.borderView(1, color: UIColor.whiteColor().CGColor)
            self.profileImageView.setImageWithURL((self.user?.profileUrl!)!)
            
            //            profileImageView.transform =  CGAffineTransformScale(profileImageView.transform, 1.25, 1.25)
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    @IBAction func onButtonHeaderViewAction(sender: UIButton) {
        TwitterClient.sharedInstance.logout()
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
