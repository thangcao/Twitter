//
//  Tweet.swift
//  Twitter
//
//  Created by Cao Thắng on 7/23/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var id: NSNumber?
    var text: String?
    var timestamp: NSDate?
    var retweetCount: Int = 0
    var favoriteCount: Int = 0
    var tweetImageUrl: NSURL?
    var imageUrlString: String?
    var isFavorited = false
    var isRetweeted = false
    var user: User?
    init(dictionary: NSDictionary) {
        id = dictionary["id"] as? NSNumber!
        text = dictionary["text"] as? String
        
        let timestampString = dictionary["created_at"] as? String
        if let timestampString = timestampString {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.dateFromString(timestampString)
        }
        if let userDictionary = dictionary["user"] as? NSDictionary {
            let user = User(dictionary: userDictionary)
            self.user = user
        }
        if let entities = dictionary["entities"] as? NSDictionary {
            if let media = entities["media"] as? NSDictionary {
                if let mediaUrl = media["media_url"] as? String {
                    tweetImageUrl = NSURL(string: mediaUrl)
                }
            }
        }
        imageUrlString = ""
        if let media = dictionary.valueForKeyPath("extended_entities.media") as? [NSDictionary] {
            if let urlString = media[0]["media_url"] as? String {
                imageUrlString = urlString
            }
        }
        
        favoriteCount = (dictionary["favorite_count"] as? Int) ?? 0
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        isFavorited = (dictionary["favorited"] as? Bool!)!
        isRetweeted = (dictionary["retweeted"] as? Bool!)!
    }
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet]{
        var tweets = [Tweet]()
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        return tweets
    }
}
