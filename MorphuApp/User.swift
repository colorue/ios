//
//  User.swift
//  Morphu
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
class User {
    
    let userId: String
    let username: String
    let email: String
    var profileImage: UIImage  //make getter and setter
    private var following = [User]()
    
    init(userId: String = "", email: String = "", username: String = "", profileImage: UIImage = UIImage()) {
        self.userId = userId
        self.username = username
        self.email = email
        self.profileImage = profileImage
    }
    
    func follow(user: User) {
        if !self.isFollowing(user) {
            following.append(user)
        }
    }
    
    func unfollow(user: User) {
        var i = 0
        for followee in self.following {
            if followee.userId == user.userId {
                self.following.removeAtIndex(i)
                return
            }
            i += 1
        }
    }
    
    func isFollowing(user: User) -> Bool {
        for followee in self.following {
            if followee.userId == user.userId {
                return true
            }
        }
        return false
    }
}