//
//  Comment.swift
//  Morphu
//
//  Created by Dylan Wight on 5/24/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class Comment {
    let commentId: String
    let user: User
    let timeStamp: NSDate
    let text: String
    
    let api = API.sharedInstance
    
    init(commentId: String = "", user: User = User(), timeStamp: NSDate = NSDate(), text: String = "") {
        self.commentId = commentId
        self.user = user
        self.timeStamp = timeStamp
        self.text = text
    }
    
    func getTimeSinceSent() -> String {
        let secondsSince = NSDate().timeIntervalSinceDate(self.timeStamp)
        switch(secondsSince) {
        case 0..<60:
            return "now"
        case 60..<3600:
            return String(Int(secondsSince/60))  + "m"
        case 3600..<3600*24:
            return String(Int(secondsSince/3600)) + "h"
        default:
            return String(Int(secondsSince/(3600 * 24))) + "d"
        }
    }
    
    func toAnyObject()-> NSDictionary {
        return ["user" : self.user.userId,
                "text" : self.text,
                "timeStamp" : api.dateFormatter.stringFromDate(self.timeStamp)]
    }
}