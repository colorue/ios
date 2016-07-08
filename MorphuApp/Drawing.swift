//
//  Drawing.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class Drawing {
    
    let timeStamp: Double
    private var drawingId: String
    private var artist: User
    private var likes = [User]()
    private var comments = [Comment]()
    private var image: UIImage?
    var delagate: DrawingDelagate?
    var drawingOfTheDay = false
    var url: NSURL?
    
    init(artist: User = User(), timeStamp: Double = 0 - NSDate().timeIntervalSince1970, drawingId: String = "") {
        self.artist = artist
        self.timeStamp = timeStamp
        self.drawingId = drawingId
    }
    
    func setDrawingId(drawingId: String) {
        self.drawingId = drawingId
    }
    
    func getDrawingId() -> String {
        return self.drawingId
    }
    
    func setProgress(progress: Float) {
        self.delagate?.setProgress(progress)
    }
    
    func setImage(image: UIImage?) {
        self.image = image
    }
    
    func getImage() -> UIImage {
        if let image = self.image {
            return image
        } else {
            return UIImage()
        }
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
        if self.likes.isEmpty { return }
        
        for liker in self.likes {
            if liker.userId == user.userId {
                self.likes.removeAtIndex(i)
                return
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
    
    func getLikes() -> [User] {
        return self.likes
    }
    
    func addComment(comment: Comment) {
        for comment_ in self.comments {
            if comment_.getCommetId() == comment.getCommetId() {
                return
            }
        }
        self.comments.append(comment)
    }
    
    func removeComment(comment: Comment) {
        var i = 0
        for comment_ in self.comments {
            if comment_.getCommetId() == comment.getCommetId() {
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
        return ["artist": self.artist.userId,
                "timeStamp": self.timeStamp,
                "url": self.url!.absoluteString]
    }
}
