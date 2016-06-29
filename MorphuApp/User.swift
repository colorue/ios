//
//  User.swift
//  Morphu
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

// MARK: Equatable
func == (lhs: User, rhs: User) -> Bool {
    return lhs.userId == rhs.userId
}

class User: Hashable {
    
    let userId: String
    let username: String
    let fullname: String
    let email: String
    var profileImage: UIImage?  //make getter and setter
    private var following = Set<User>()
    private var followers = Set<User>()
    private var drawings = [Drawing]()
    
    private var newestDrawing: Double = 0
    
    private var fullUserLoaded = false
    
    var hashValue: Int {
        return userId.hashValue
    }
    
    func setfullUserLoaded() {
        self.fullUserLoaded = true
    }
    
    func getfullUserLoaded() -> Bool {
        return self.fullUserLoaded
    }
    
    init(userId: String = "", email: String = "", username: String = "", fullname: String = "", profileImage: UIImage? = nil) {
        self.userId = userId
        self.username = username
        self.fullname = fullname
        self.email = email
        self.profileImage = profileImage
    }
    
    func getFollowing() -> Set<User> {
        return self.following
    }
    
    func follow(user: User) {
        following.insert(user)
    }
    
    func unfollow(user: User) {
        following.remove(user)
    }
    
    func isFollowing(user: User) -> Bool {
        for followee in self.following {
            if followee.userId == user.userId {
                return true
            }
        }
        return false
    }
    
    func addFollower(user: User) {
        followers.insert(user)
    }
    
    func removeFollower(user: User) {
        followers.remove(user)
    }
    
    func getFollowers() -> Set<User> {
        return self.followers
    }
    
    func addDrawing(drawing: Drawing) {
        if drawing.timeStamp < newestDrawing {
            self.newestDrawing = drawing.timeStamp
            self.drawings.insert(drawing, atIndex: 0)
        } else {
            self.drawings.append(drawing)
        }
    }
    
    func removeDrawing(drawing: Drawing) {
        var i = 0
        for drawing_ in self.drawings {
            if drawing_.getDrawingId() == drawing.getDrawingId() {
                self.drawings.removeAtIndex(i)
                return
            }
            i += 1
        }
    }
    
    func getDrawings() -> [Drawing] {
        return self.drawings
    }
}