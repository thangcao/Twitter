//
//  FormatDateUtil.swift
//  Twitter
//
//  Created by Cao Thắng on 7/26/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import Foundation
struct FortmartDateUtil {
    static func formatDateToShortDate(timestamp: NSDate) -> String {
        print (timestamp)
        let minutes = 60
        let hour = minutes * 60
        let day = hour * 24
        let week = day * 7
        var result: String = ""
        let elapsedTime = NSDate().timeIntervalSinceDate(timestamp)
        print(elapsedTime)
        let duration = Int(elapsedTime)
        
        if duration < minutes {
            result = "\(duration)s"
        } else if duration >= minutes && duration < hour {
            result = "\(duration / minutes)m"
        } else if duration >= hour && duration < day {
            result =  "\(duration / hour)h"
        } else if duration >= day && duration < week {
            result =  "\( duration / day)d"
        } else {
            let dateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "MMM dd YYY HH:mm"
            result = dateFormatter.stringFromDate(timestamp)
        }
        
        return result
    }
    
    static func formatDateToLongDate(timestamp: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "h:mm a '-' MMMM dd, yyyy"
        dateFormatter.AMSymbol = "AM"
        dateFormatter.PMSymbol = "PM"
        return  dateFormatter.stringFromDate(timestamp)
    }
}