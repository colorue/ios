//
//  Prompt.swift
//  Colorue
//
//  Created by Dylan Wight on 8/6/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class Prompt {
    let user: User
    let timeStamp: Double
    let text: String
    private var promptId: String
    var drawings = [Drawing]()
    
    let api = API.sharedInstance
    
    init(promptId: String = "", user: User = User(), timeStamp: Double = 0 - NSDate().timeIntervalSince1970, text: String = "") {
        self.promptId = promptId
        self.user = user
        self.timeStamp = timeStamp
        self.text = text
    }
    
    func setPromptIdd(promptId: String) {
        self.promptId = promptId
    }
    
    func getPromptId() -> String {
        return promptId
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