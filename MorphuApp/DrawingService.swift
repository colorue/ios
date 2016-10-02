////
////  DrawingService.swift
////  Colorue
////
////  Created by Dylan Wight on 10/2/16.
////  Copyright © 2016 Dylan Wight. All rights reserved.
////
//
//import Foundation
//import Firebase
//import RealmSwift
//import Realm
//
//struct DrawingService {
//    fileprivate let myRootRef = FIRDatabase.database().reference()
//    let realm = try! Realm()
//    
//    let basePath = "drawings"
//    
//    func get(id: String, callback: @escaping (Drawing?) -> ()) {
//        myRootRef.child("\(basePath)/\(id)").observeSingleEvent(of: .value, with: { snapshot in
//            
//            if let json = snapshot.value as? [String: Any] {
//                if let drawing = Drawing(JSON: json) {
//                    try! self.realm.write() {
//                        self.realm.add(drawing, update: true)
//                    }
//                    callback(drawing)
//                }
//            }
//        })
//    }
//    
//    func add(drawing: Drawing) {
//        guard let activeUser = API.sharedInstance.activeUser else { return }
//        
//        let newComment = myRootRef.child("comments").childByAutoId()
//        
//        let comment = Comment(id: newComment.key, text: commentText, user: activeUser)
//        
//        drawing.add(comment: comment)
//        print(comment.toJSON())
//        newComment.setValue(comment.toJSON())
//        myRootRef.child("drawings/\(drawing.getDrawingId())/comments/\(newComment.key)").setValue(true)
//        
//        API.sharedInstance.sendPushNotification("\(activeUser.username) commented on your drawing", recipient: drawing.getArtist().userId, badge: "+0")
//    }
//    
//    func delete(drawing: Drawing) {
//        drawing.remove(drawing: comment)
//        myRootRef.child("comments/\(comment.id)").removeValue()
//        myRootRef.child("drawings/\(drawing.getDrawingId())/comments/\(comment.id)").removeValue()
//    }
//    
//    func report(comment: Drawing) {
//        guard let activeUser = API.sharedInstance.activeUser else { return }
//        myRootRef.child("reported/comments/\(comment.id)/\(activeUser.userId)").setValue(0 - Date().timeIntervalSince1970)
//    }
//}
