//
//  Comment.swift
//  Colorue
//
//  Created by Dylan Wight on 5/24/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class Comment {
    let user: User
    let timeStamp: Double
    let text: String
    private var commentId: String
    
    let api = API.sharedInstance
    
    init(commentId: String = "", user: User = User(), timeStamp: Double = 0 - NSDate().timeIntervalSince1970, text: String = "") {
        self.commentId = commentId
        self.user = user
        self.timeStamp = timeStamp
        self.text = text
    }
    
    func setCommentId(commentId: String) {
        self.commentId = commentId
    }
    
    func getCommetId() -> String {
        return self.commentId
    }
    
    func getTimeSinceSent() -> String {
        let secondsSince =  NSDate().timeIntervalSince1970 + self.timeStamp
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
                "timeStamp" : self.timeStamp]
    }
}