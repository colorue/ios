//
//  Comment.swift
//  Colorue
//
//  Created by Dylan Wight on 5/24/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import ObjectMapper

//class Comment {
//    let user: User
//    let timeStamp: TimeStamp
//    let text: String
//    fileprivate var commentId: String
//    
//    let api = API.sharedInstance
//    
//    init(commentId: String = "", user: User = User(), timeStamp: Double = 0 - Date().timeIntervalSince1970, text: String = "") {
//        self.commentId = commentId
//        self.user = user
//        self.timeStamp = timeStamp
//        self.text = text
//    }
//    
//    func setCommentId(_ commentId: String) {
//        self.commentId = commentId
//    }
//    
//    func getCommetId() -> String {
//        return self.commentId
//    }
//    
//    func toAnyObject()-> NSDictionary {
//        return ["user" : self.user.userId,
//                "text" : self.text,
//                "timeStamp" : self.timeStamp]
//    }
//}

class Comment: APIObject {
    
    public dynamic var id: String? = ""
    public dynamic var text: String? = ""
    public dynamic var timeStamp: Double = 0
    public dynamic var user: User?
    
    convenience init(id: String, text: String, user: User, timeStamp: Double = -Date().timeIntervalSince1970) {
        self.init()
        self.id = id
        self.user = user
        self.timeStamp = timeStamp
        self.text = text
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    public override func mapping(map: Map) {
        id <- map["id"]
        text <- map["text"]
        timeStamp <- map["timeStamp"]
        user <- map["user"]
    }
}
