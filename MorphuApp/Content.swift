//
//  Content.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class Content {
    
    let model = API.sharedInstance
    let isDrawing: Bool
    let text: String
    let timeSent: NSDate
    private var chainId: String
    private var contentId: String
    private var author: User
    
    init(author: User, timeSent: NSDate = NSDate(), isDrawing: Bool, text: String, chainId: String, contentId: String) {
        self.author = author
        self.timeSent = timeSent
        self.isDrawing = isDrawing
        self.text = text
        self.chainId = chainId
        self.contentId = contentId
    }
    
    convenience init() {
        self.init(author: User(), timeSent: NSDate(), isDrawing: false, text: "", chainId: "", contentId: "")
    }
    
    func setContentId(contentId: String) {
        self.contentId = contentId
    }
    
    func getContentId() -> String {
        return self.contentId
    }
    
    func setAuthor(author: User) {
        self.author = author
    }
    
    func getAuthor() -> User {
        return self.author
    }
    
    func setChainId(chainId: String) {
        self.chainId = chainId
    }
    
    func getChainId() -> String {
        return self.chainId
    }
    
    func getTimeSinceSent() -> String {
        let secondsSince = NSDate().timeIntervalSinceDate(self.timeSent)
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
        return ["author": self.author.userId,
                "isDrawing": self.isDrawing,
                "text": self.text,
                "chainId": self.chainId,
                "timeSent": model.dateFormatter.stringFromDate(self.timeSent)]
    }
}
