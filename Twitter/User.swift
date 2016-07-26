//
//  User.swift
//  Twitter
//
//  Created by Cao Thắng on 7/23/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var screenName: String?
    var profileUrl: NSURL?
    var tagline: String?
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        let profileUrlString = dictionary["profile_image_url"] as? String
        if let profileString = profileUrlString {
            profileUrl = NSURL(string: profileString)
        }
        tagline = dictionary["description"] as? String
    }
    static let userDigLogoutNotification = "UserDidLogout"
    
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                let userData = defaults.objectForKey("currentUSerData") as? NSData
                if let userData = userData {
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(userData, options: []) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        set(user){
            let defaults = NSUserDefaults.standardUserDefaults()
            if let user = user {
                let data = try! NSJSONSerialization.dataWithJSONObject( user.dictionary!, options: [])
                defaults.setObject(data, forKey: "currentUSerData")
                
            } else {
                defaults.setObject(nil, forKey: "currentUSerData")
            }
            defaults.synchronize()
        }
    }
}
