//
//  Drawing.swift
//  Colorue
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import ObjectMapper
import RealmSwift

class Drawing {
    
    var id: String
    var timeStamp: TimeStamp
    var user: User
    var likes = [User]()
    var comments = [Comment]()
    var image = UIImage()
    var drawingOfTheDay = false
    var imageUrl: URL?
    
    init(user: User = User(), timeStamp: Double = 0 - Date().timeIntervalSince1970, id: String = "") {
        self.user = user
        self.timeStamp = timeStamp
        self.id = id
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
    
    func toAnyObject()-> NSDictionary {
        return ["artist": self.user.userId,
                "timeStamp": self.timeStamp,
                "url": self.imageUrl!.absoluteString]
    }
}
