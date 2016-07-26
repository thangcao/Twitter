//
//  HandleUtil.swift
//  Twitter
//
//  Created by Cao Thắng on 7/25/16.
//  Copyright © 2016 thangcao. All rights reserved.
//

import Foundation

struct HandleUtil {
    static func trimWhiteSpace(data: String?) -> String {
        if data == "" {
            return ""
        }
        return data!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}