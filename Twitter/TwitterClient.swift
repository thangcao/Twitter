//
//  TwitterClient.swift
//  Twitter
//
//  Created by Cao Thắng on 7/23/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
class TwitterClient: BDBOAuth1SessionManager {
    
    
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com"), consumerKey: "AV8jhXPeiWSDyjMmslQ9XgybY", consumerSecret: "0kzjvI7iUrXktQBlXwdkKGWKgTWVawYj9bPx0IqU2jPBtL5QWn")
    var loginSuccess: (() -> ())?
    var loginFailure: ((NSError) -> ())?
    
    func homeTimeLine ( count: Int?, maxId: NSNumber?,success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        
        var params = [String : AnyObject]()
        
        if count != nil {
            params["count"] = count!
        }
        
        if maxId != nil {
            params["max_id"] = maxId!
        }
        GET("1.1/statuses/home_timeline.json", parameters: params, progress: nil, success: { (task : NSURLSessionDataTask, response: AnyObject?) in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            success(tweets)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }
    func currentAccount(success: (User) -> (), failure:(NSError) -> ()) {
        GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task : NSURLSessionDataTask, response: AnyObject?) in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
        })
    }
    func login(success: ()-> () , failure: (NSError) -> ()) {
        loginSuccess = success
        loginFailure = failure
        TwitterClient.sharedInstance.deauthorize()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "twitterdemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            print("I got a token")
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
            UIApplication.sharedApplication().openURL(url)
            
        }) { (error: NSError!) in
            print("error: \(error.localizedDescription)")
            self.loginFailure?(error)
        }
    }
    func logout() {
        User.currentUser = nil
        deauthorize()
        NSNotificationCenter.defaultCenter().postNotificationName(User.userDigLogoutNotification, object: nil)
    }
    func handleOpenUrl(url : NSURL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) in
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            self.currentAccount({ (user: User) in
                User.currentUser = user
                self.loginSuccess?()
                }, failure: { (error: NSError) in
                    self.loginFailure?(error)
            })
            self.loginSuccess?()
        }) { (error: NSError!) in
            print("error \(error.localizedDescription)")
            self.loginFailure?(error)
        }
        
    }
    // Favorite
    func favoriteTweet(id: NSNumber, success: (response: AnyObject?) -> (), failure:(NSError) -> ()) {
        var params = [String : AnyObject]()
        params["id"] = id
        POST("1.1/favorites/create.json", parameters: params, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            success (response: response!)
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
        }
    }
    // Unfavorite
    func unFavoriteTweet(id: NSNumber, success: (response: AnyObject?) -> (), failure:(NSError) -> ()) {
        var params = [String : AnyObject]()
        params["id"] = id
        POST("1.1/favorites/destroy.json", parameters: params, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            success (response: response!)
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
        }
    }
    // ReTweet
    func reTweet(id: NSNumber, success: (response: AnyObject?) -> (), failure:(NSError) -> ()){
        POST("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            success (response: response!)
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
        }
    }
    // GetTweetID
    func getRetweetedId(id: NSNumber, success: (response: AnyObject?) -> (), failure:(NSError) -> ()) {
        
        var params = [String : AnyObject]()
        params["include_my_retweet"] = true
        GET("1.1/statuses/show/\(id).json", parameters: params, progress: nil, success: { (task:NSURLSessionDataTask, response: AnyObject?) in
            let tweet = response as! NSDictionary
            let curUserRetweet = tweet["current_user_retweet"] as! NSDictionary
            let retweetedId = curUserRetweet["id"] as? NSNumber
            success(response: retweetedId!)
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            print(error)
            failure(error)
        }
    }
    // UnReTweet
    
    func unReTweet(id: NSNumber, success: (response: AnyObject?) -> (), failure:(NSError) -> ()){
        POST("1.1/statuses/destroy/\(id).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            success (response: response!)
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
        }
    }
    // Update Tweet
    func updateTweet(text: String, success: (response: Tweet?) -> (), failure:(NSError) -> ()) {
        
        var params = [String : AnyObject]()
        params["status"] = text
        POST("1.1/statuses/update.json", parameters: params, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let newTweet = Tweet(dictionary: response as! NSDictionary)
            success (response: newTweet)
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
        }
    }
    // Reply Tweet
    func replyTweet(text: String, originalId: NSNumber, success: (response: Tweet?) -> (), failure:(NSError) -> ()) {
        
        var params = [String : AnyObject]()
        params["status"] = text
        params["in_reply_to_status_id"] = originalId
        POST("1.1/statuses/update.json", parameters: params, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let newTweet = Tweet(dictionary: response as! NSDictionary)
            success (response: newTweet)
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            failure(error)
        }
    }
   

}
