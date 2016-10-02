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

class CommentService {
    fileprivate let myRootRef = FIRDatabase.database().reference()
    let realm = try! Realm()
    
    let basePath = "commments"
    
    func add(comment: Comment, to drawing: Drawing) {
        myRootRef.child("\(basePath)/\(comment.id)/\(drawing.getDrawingId())").setValue(true)
    }
    
    func get(commentId: String, callback: @escaping (Comment?) -> ()) {
        myRootRef.child("\(basePath)/\(commentId)").observeSingleEvent(of: .value, with: { snapshot in
            
            if let json = snapshot.value as? [String: Any] {
                if let comment = Comment(JSON: json) {
                    try! self.realm.write() {
                        self.realm.add(comment, update: true)
                    }
                    callback(comment)
                }
            }
        })
    }
    
    func addComment(_ drawing: Drawing, text: String) {
        guard let activeUser = API.sharedInstance.activeUser else { return }
        
        let newComment = myRootRef.child("comments").childByAutoId()
        
        let comment = Comment(id: newComment.key, text: text, user: activeUser)

        drawing.addComment(comment)
        newComment.setValue(comment.toJSON())
        myRootRef.child("drawings/\(drawing.getDrawingId())/comments/\(newComment.key)").setValue(true)
        
        API.sharedInstance.sendPushNotification("\(activeUser.username) commented on your drawing", recipient: drawing.getArtist().userId, badge: "+0")
    }
    
    func deleteComment(_ drawing: Drawing, comment: Comment) {
        drawing.removeComment(comment)
        myRootRef.child("comments/\(comment.id)").removeValue()
        myRootRef.child("drawings/\(drawing.getDrawingId())/comments/\(comment.id)").removeValue()
    }
}
