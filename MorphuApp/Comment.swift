//
//  Comment.swift
//  Colorue
//
//  Created by Dylan Wight on 5/24/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

class Comment {
    let user: User
    let timeStamp: TimeStamp
    let text: String
    var id: String
    
    init(id: String = "", user: User = User(), timeStamp: Double = 0 - Date().timeIntervalSince1970, text: String = "") {
        self.id = id
        self.user = user
        self.timeStamp = timeStamp
        self.text = text
    }
    
    func toAnyObject()-> NSDictionary {
        return ["user" : self.user.userId,
                "text" : self.text,
                "timeStamp" : self.timeStamp]
    }
}
