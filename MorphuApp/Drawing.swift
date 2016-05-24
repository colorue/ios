//
//  Drawing.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class Drawing {
    
    let api = API.sharedInstance
    let text: String
    let timeStamp: NSDate
    private var drawingId: String
    private var artist: User
    private var likes = [User]()
    private var comments = [Comment]()
    
    init(artist: User, timeStamp: NSDate = NSDate(), text: String, drawingId: String) {
        self.artist = artist
        self.timeStamp = timeStamp
        self.text = text
        self.drawingId = drawingId
        
        
        comments.append(Comment(commentId: "1", user: api.getActiveUser(), text: "Hello There"))


    }
    
    convenience init() {
        self.init(artist: User(), timeStamp: NSDate(), text: "", drawingId: "")
    }
    
    func setDrawingId(drawingId: String) {
        self.drawingId = drawingId
    }
    
    func getDrawingId() -> String {
        return self.drawingId
    }
    
    func setArtist(artist: User) {
        self.artist = artist
    }
    
    func getArtist() -> User {
        return self.artist
    }
    
    func like(user: User) {
        if !liked(user) {
            self.likes.append(user)
        }
    }
    
    func unlike(user: User) {
        var i = 0
        for liker in likes {
            if liker.userId == user.userId {
                self.likes.removeAtIndex(i)
                break
            }
            i += 1
        }
    }
    
    func liked(user: User) -> Bool {
        for liker in self.likes {
            if liker.userId == user.userId {
                return true
            }
        }
        return false
    }
    
    func liked() -> Bool {
        for liker in self.likes {
            if liker.userId == api.getActiveUser().userId {
                return true
            }
        }
        return false
    }
    
    func getLikes() -> [User] {
        return self.likes
    }
    
    func addComment(comment: Comment) {
        self.comments.append(comment)
    }
    
    func removeComment(comment: Comment) {
        var i = 0
        for comment_ in self.comments {
            if comment_.commentId == comment.commentId {
                self.comments.removeAtIndex(i)
                break
            }
            i += 1
        }
    }
    
    func getComments() -> [Comment] {
        return self.comments
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
        return ["artist": self.artist.userId,
                "text": self.text,
                "timeSent": api.dateFormatter.stringFromDate(self.timeStamp)]
    }
}
