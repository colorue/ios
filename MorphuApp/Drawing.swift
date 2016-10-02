//
//  Drawing.swift
//  Colorue
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class Drawing {
    
    let timeStamp: TimeStamp
    fileprivate var drawingId: String
    fileprivate var artist: User
    fileprivate var likes = [User]()
    fileprivate var comments = [Comment]()
    fileprivate var image: UIImage?
    var drawingOfTheDay = false
    var url: URL?
    
    init(artist: User = User(), timeStamp: Double = 0 - Date().timeIntervalSince1970, drawingId: String = "") {
        self.artist = artist
        self.timeStamp = timeStamp
        self.drawingId = drawingId
    }
    
    func setDrawingId(_ drawingId: String) {
        self.drawingId = drawingId
    }
    
    func getDrawingId() -> String {
        return self.drawingId
    }
    
    func setImage(_ image: UIImage?) {
        self.image = image
    }
    
    func getImage() -> UIImage {
        if let image = self.image {
            return image
        } else {
            return UIImage()
        }
    }
    
    func setArtist(_ artist: User) {
        self.artist = artist
    }
    
    func getArtist() -> User {
        return self.artist
    }
    
    func like(_ user: User) {
        if !liked(user) {
            self.likes.append(user)
        }
    }
    
    func unlike(_ user: User) {
        var i = 0
        if self.likes.isEmpty { return }
        
        for liker in self.likes {
            if liker.userId == user.userId {
                self.likes.remove(at: i)
                return
            }
            i += 1
        }
    }
    
    func liked(_ user: User) -> Bool {
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
    
    func add(comment: Comment?) {
        guard let comment = comment else { return }
        
        for comment_ in self.comments {
            if comment_.id == comment.id {
                return
            }
        }
        self.comments.append(comment)
    }
    
    func remove(comment: Comment) {
        var i = 0
        for comment_ in self.comments {
            if comment_.id == comment.id {
                self.comments.remove(at: i)
                break
            }
            i += 1
        }
    }
    
    func getComments() -> [Comment] {
        return self.comments
    }
    
    func toAnyObject()-> NSDictionary {
        return ["artist": self.artist.userId,
                "timeStamp": self.timeStamp,
                "url": self.url!.absoluteString]
    }
}
//
//class Drawing: APIObject {
//    
//    public dynamic var id: String? = ""
//    public dynamic var text: String? = ""
//    public dynamic var user: String? = ""
//    public dynamic var timeStamp: Double = 0
//    
//    convenience init(id: String, text: String, user: User, timeStamp: Double = -Date().timeIntervalSince1970) {
//        self.init()
//        self.id = id
//        self.user = user.userId
//        self.timeStamp = timeStamp
//        self.text = text
//    }
//    
//    override class func primaryKey() -> String? {
//        return "id"
//    }
//    
//    public override func mapping(map: Map) {
//        id <- map["id"]
//        text <- map["text"]
//        user <- map["user"]
//        timeStamp <- map["timeStamp"]
//    }
//}
