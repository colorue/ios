//
//  UserService.swift
//  Colorue
//
//  Created by Dylan Wight on 10/2/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Firebase

struct UserService {
    let myRootRef = FIRDatabase.database().reference()
    
    var activeUser: User {
        return API.sharedInstance.getActiveUser()
    }

    func get(userId: String, callback: @escaping (User) -> ()) {
        self.myRootRef.child("users/\(userId)").observeSingleEvent(of: .value, with: {snapshot in
            if (!snapshot.exists()) { return }
            
            guard let value = snapshot.value as? [String : AnyObject] else { return }
            
            let username = value["username"] as! String
            let email = value["email"] as! String
            let fullname = value["fullName"] as! String
            let profileURLString = value["photoURL"] as? String ?? ""
            
            print(profileURLString)
            let newUser = User(userId: userId, email: email, username: username, fullname: fullname, profileURL: profileURLString)

            callback(newUser)
        })
    }
    
    func follow(_ user: User) {
        myRootRef.child("users/\(activeUser.userId)/following/\(user.userId)").setValue(true)
        myRootRef.child("users/\(user.userId)/followers/\(activeUser.userId)").setValue(true)
        PushService().send(message: "\(activeUser.username) is following you", to: user)
    }
    
    func unfollow(_ user: User) {
        myRootRef.child("users/\(activeUser.userId)/following/\(user.userId)").removeValue()
        myRootRef.child("users/\(user.userId)/followers/\(activeUser.userId)").removeValue()
    }
    
    func search(for name: String, callback: @escaping (User)->()) {
        let lowercase = name.lowercased()
        let searchStart = lowercase
        let searchEnd = lowercase + "z"
        myRootRef.child("userLookup/usernames").removeAllObservers()
        myRootRef.child("userLookup/usernames").queryOrderedByKey()
            .queryStarting(atValue: searchStart)
            .queryEnding(atValue: searchEnd)
            .queryLimited(toFirst: 16)
            .observe(.childAdded, with: { snapshot in
                let userId = snapshot.value as! String
                UserService().get(userId: userId, callback: { (user: User) -> () in
                    callback(user)
                })
            })
    }

    func getFull(user: User) {
        if !user.getfullUserLoaded() {
            self.myRootRef.child("users/\(user.userId)/following").observe(.childAdded, with: {snapshot in
                UserService().get(userId: snapshot.key, callback: { (follow: User) -> () in
                    user.follow(follow)
                    self.myRootRef.child("users/\(follow.userId)/drawings").observe(.childAdded, with: {snapshot in
                        self.myRootRef.child("users/\(self.activeUser.userId)/wall/\(snapshot.key)").setValue(snapshot.value)
                    })
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/following").observe(.childRemoved, with: {snapshot in
                UserService().get(userId: snapshot.key, callback: { (unfollow: User) -> () in
                    user.unfollow(unfollow)
                    self.myRootRef.child("users/\(unfollow.userId)/drawings").observe(.childAdded, with: {snapshot in
                        self.myRootRef.child("users/\(self.activeUser.userId)/wall/\(snapshot.key)").removeValue()
                    })
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/followers").observe(.childAdded, with: {snapshot in
                UserService().get(userId: snapshot.key, callback: { (follower: User) -> () in
                    user.addFollower(follower)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/followers").observe(.childRemoved, with: {snapshot in
                UserService().get(userId: snapshot.key, callback: { (unfollower: User) -> () in
                    user.removeFollower(unfollower)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/drawings").queryOrderedByValue().observe(.childAdded, with: {snapshot in
                DrawingService().get(id: snapshot.key, callback: { (drawing: Drawing, new: Bool) -> () in
                    user.addDrawing(drawing)
                })
            })
            user.setfullUserLoaded()
        }
    }

    func loadFullUser(_ user: User) {
        if !user.getfullUserLoaded() {
            self.myRootRef.child("users/\(user.userId)/following").observe(.childAdded, with: {snapshot in
                UserService().get(userId: snapshot.key, callback: { (follow: User) -> () in
                    user.follow(follow)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/following").observe(.childRemoved, with: {snapshot in
                UserService().get(userId: snapshot.key, callback: { (unfollow: User) -> () in
                    user.unfollow(unfollow)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/followers").observe(.childAdded, with: {snapshot in
                UserService().get(userId: snapshot.key, callback: { (follower: User) -> () in
                    user.addFollower(follower)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/followers").observe(.childRemoved, with: {snapshot in
                UserService().get(userId: snapshot.key, callback: { (unfollower: User) -> () in
                    user.removeFollower(unfollower)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/drawings").queryOrderedByValue().observe(.childAdded, with: {snapshot in
                DrawingService().get(id: snapshot.key, callback: { (drawing: Drawing, new: Bool) -> () in
                    user.addDrawing(drawing)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/followers").observe(.childRemoved, with: {snapshot in
                DrawingService().get(id: snapshot.key, callback: { (drawing: Drawing, new: Bool) -> () in
                    user.removeDrawing(drawing)
                })
            })
            user.setfullUserLoaded()
        }
    }
}
