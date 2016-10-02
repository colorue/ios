//
//  CommentService.swift
//  Colorue
//
//  Created by Dylan Wight on 10/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
import Firebase
import RealmSwift
import Realm

struct CommentService {
    let myRootRef = FIRDatabase.database().reference()
    let realm = try! Realm()
    let basePath = "comments"
    
    func get(id: String, callback: @escaping (Comment?) -> ()) {
        myRootRef.child("\(basePath)/\(id)").observeSingleEvent(of: .value, with: { snapshot in
            guard let json = snapshot.value as? [String: Any] else { return }
            if let comment = Comment(JSON: json) {
                try! self.realm.write() {
                    self.realm.add(comment, update: true)
                }
                callback(comment)
            }
        })
    }
    
    func add(commentText: String, to drawing: Drawing) {
        guard let activeUser = API.sharedInstance.activeUser else { return }
        
        let newComment = myRootRef.child("comments").childByAutoId()
        let comment = Comment(id: newComment.key, text: commentText, user: activeUser)
        drawing.add(comment: comment)
        newComment.setValue(comment.toJSON())
        myRootRef.child("drawings/\(drawing.getDrawingId())/comments/\(newComment.key)").setValue(true)
        PushService().send(message: "\(activeUser.username) commented on your drawing", to: drawing.getArtist())
    }
    
    func delete(comment: Comment, from drawing: Drawing) {
        drawing.remove(comment: comment)
        myRootRef.child("comments/\(comment.id)").removeValue()
        myRootRef.child("drawings/\(drawing.getDrawingId())/comments/\(comment.id)").removeValue()
    }
    
    func report(comment: Comment) {
        guard let activeUser = API.sharedInstance.activeUser else { return }
        myRootRef.child("reported/comments/\(comment.id)/\(activeUser.userId)").setValue(0 - Date().timeIntervalSince1970)
    }
}
