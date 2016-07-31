//
//  UserHeaderCellTableViewCell.swift
//  Twitter
//
//  Created by Cao Thắng on 7/30/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit

class UserHeaderCell: UITableViewCell {

    @IBOutlet weak var buttonFromHeaderView: UIButton!
    
    @IBOutlet weak var constrainsRightOfViewHeader: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageView: CircleImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var idNameLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followerCountLabel: UILabel!
    
    @IBOutlet weak var tweetCountLabel: UILabel!
    
    var user: User? {
        didSet {
            userNameLabel.text = (user?.name)!
            idNameLabel.text = "@\((user?.screenName)!)"
            tweetCountLabel.text = "\((user?.retweetCount)!)"
            followingCountLabel.text = "\((user?.followingCount)!)"
            followerCountLabel.text =  "\((user?.followerCount)!)"
            profileImageView.borderView(1, color: UIColor.whiteColor().CGColor)
            profileImageView.setImageWithURL((user?.profileUrl!)!)
//            profileImageView.transform =  CGAffineTransformScale(profileImageView.transform, 1.25, 1.25)

        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if buttonFromHeaderView != nil {
            buttonFromHeaderView.clipsToBounds = true
            buttonFromHeaderView.layer.borderColor = UIColor.cyanColor()
                .CGColor
            buttonFromHeaderView.layer.borderWidth = 1
        }
      
    }

    @IBAction func onButtonHeaderViewAction(sender: UIButton) {
         TwitterClient.sharedInstance.logout()
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
