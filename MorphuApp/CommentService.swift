//
//  CommentService.swift
//  Colorue
//
//  Created by Dylan Wight on 10/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
import Firebase

struct CommentService {
    let myRootRef = FIRDatabase.database().reference()
    let basePath = "comments"
    
    func get(id: String, callback: @escaping (Comment?) -> ()) {
        myRootRef.child("\(basePath)/\(id)").observeSingleEvent(of: .value, with: { snapshot in
            
            guard let value = snapshot.value as? [String : AnyObject] , snapshot.exists() else { return }
            
            let text = value["text"] as! String
            let timeStamp = value["timeStamp"] as! Double
            
            UserService().get(userId: value["user"] as! String, callback: { (user: User) -> () in
                callback(Comment(id: id, user: user, timeStamp: timeStamp, text: text))
            })
        })
    }
    
    func add(commentText: String, to drawing: Drawing) {
        guard let activeUser = API.sharedInstance.activeUser else { return }
        
        parse(commentText, drawing: drawing)
        
        let newComment = myRootRef.child("comments").childByAutoId()
        let comment = Comment(id: newComment.key, user: activeUser, text: commentText)
        drawing.add(comment: comment)
        newComment.setValue(comment.toAnyObject())
        myRootRef.child("drawings/\(drawing.id)/comments/\(newComment.key)").setValue(true)
        PushService().send(message: "\(activeUser.username) commented on your drawing", to: drawing.user)
    }
    
    func delete(comment: Comment?, from drawing: Drawing) {
        guard let comment = comment else { return }
        
        drawing.remove(comment: comment)
        myRootRef.child("comments/\(comment.id)").removeValue()
        myRootRef.child("drawings/\(drawing.id)/comments/\(comment.id)").removeValue()
    }
    
    func report(comment: Comment?) {
        guard let comment = comment, let activeUser = API.sharedInstance.activeUser else { return }

        myRootRef.child("reported/comments/\(comment.id)/\(activeUser.userId)").setValue(0 - Date().timeIntervalSince1970)
    }
    
    private func parse(_ comment: String, drawing: Drawing) {
        let words = comment.components(separatedBy: " ")
        
        for word in words {
            if word.hasPrefix("#") {
                var hashTag = word
                hashTag.remove(at: word.startIndex)
                HashTagService().add(hashtag: HashTag(text: hashTag), to: drawing)
            } else if word.hasPrefix("@") {
                var username = word
                username.remove(at: word.startIndex)
                UserService().search(for: username, callback: { user in
                    let message = "\(API.sharedInstance.getActiveUser().username) mentioned you in a comment"
                    PushService().send(message: message, to: user)
                })
            }
        }
    }
}
