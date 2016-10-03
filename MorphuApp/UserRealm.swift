//
//  UserRealm.swift
//  Colorue
//
//  Created by Dylan Wight on 10/2/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import ObjectMapper

class UserRealm: APIObject {
    
    public dynamic var id: String? = ""
    public dynamic var text: String? = ""
    public dynamic var user: String? = ""
    public dynamic var timeStamp: Double = 0
    
    convenience init(id: String, text: String, user: User, timeStamp: Double = -Date().timeIntervalSince1970) {
        self.init()
        self.id = id
        self.user = user.userId
        self.timeStamp = timeStamp
        self.text = text
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    public override func mapping(map: Map) {
        id <- map["id"]
        text <- map["text"]
        user <- map["user"]
        timeStamp <- map["timeStamp"]
    }
}
