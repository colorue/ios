//
//  DrawingService.swift
//  Colorue
//
//  Created by Dylan Wight on 10/2/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
import Firebase

struct DrawingService {
    let myRootRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference()
    
    var activeUser: User {
        return API.sharedInstance.getActiveUser()
    }
    
    var delagate: APIDelagate?
    
    let basePath = "drawings"

    func get(id: String, callback: @escaping (Drawing, Bool) -> ()) {

        self.myRootRef.child("drawings/\(id)").observeSingleEvent(of: .value, with: {snapshot in
            if (!snapshot.exists()) { return }

            guard let value = snapshot.value as? [String:AnyObject] else { return }

            UserService().get(userId: value["artist"] as! String, callback: { (artist: User) -> () in

                let drawing = Drawing(user: artist, timeStamp: value["timeStamp"] as! Double, id: id)

                if let urlString = value["url"] as?  String {
                    drawing.imageUrl = URL(string: urlString)
                } else {
                    API.sharedInstance.setDrawingURL(id, callback: { imageUrl in
                        drawing.imageUrl = imageUrl
                    })
                }

                self.myRootRef.child("drawings/\(id)/likes").observe(.childAdded, with: {snapshot in
                    UserService().get(userId: snapshot.key, callback: { (liker: User) -> () in
                        drawing.like(liker)
                    })
                })

                self.myRootRef.child("drawings/\(id)/likes").observe(.childRemoved, with: {snapshot in
                    UserService().get(userId: snapshot.key, callback: { (unliker: User) -> () in
                        drawing.unlike(unliker)
                    })
                })

                self.myRootRef.child("drawings/\(id)/comments").observe(.childAdded, with: {snapshot in
                    CommentService().get(id: snapshot.key, callback: { comment in
                        drawing.add(comment: comment)
                    })
                })
                
                callback(drawing, true)
            })
        })
    }

    func postDrawing(_ drawing: Drawing, progressCallback: @escaping (Float) -> (), finishedCallback: @escaping (Bool) -> ()) {
        let newDrawing = myRootRef.child("drawings").childByAutoId()
        drawing.id = newDrawing.key
        
        API.sharedInstance.uploadImage(drawing, progressCallback: progressCallback, finishedCallback:  { uploaded in
            if uploaded {
                drawing.user = self.activeUser
                API.sharedInstance.setDrawingURL(drawing.id, callback: { imageUrl in
                    drawing.imageUrl = imageUrl
                    newDrawing.setValue(drawing.toAnyObject())
                    self.myRootRef.child("users/\(self.activeUser.userId)/drawings/\(drawing.id)").setValue(drawing.timeStamp)
                    self.myRootRef.child("users/\(self.activeUser.userId)/wall/\(drawing.id)").setValue(drawing.timeStamp)
                })
            }
            finishedCallback(uploaded)
        })
    }
    
    func deleteDrawing(_ drawing: Drawing) {
        myRootRef.child("drawings/\(drawing.id)").removeValue()
        myRootRef.child("users/\(activeUser.userId)/drawings/\(drawing.id)").removeValue()
        myRootRef.child("users/\(activeUser.userId)/wall/\(drawing.id)").removeValue()
        
        let drawingRef = storageRef.child("drawings/\(drawing.id).png")
        
        drawingRef.delete { (error) -> Void in
            if (error != nil) {
                print("File deletion error")
            } else {
                self.delagate?.refresh()
            }
        }
    }
    
    func makeProfilePic(_ drawing: Drawing) {
        myRootRef.child("users/\(activeUser.userId)/photoURL").setValue(drawing.imageUrl?.absoluteString)
        activeUser.profileURL = drawing.imageUrl?.absoluteString ?? ""
        delagate?.refresh()
    }
    
    func like(_ drawing: Drawing) {
        drawing.like(activeUser)
        myRootRef.child("drawings/\(drawing.id)/likes/\(activeUser.userId)").setValue(true)
        PushService().send(message: "\(activeUser.username) liked your drawing", to: drawing.user)
    }
    
    func unlike(_ drawing: Drawing) {
        drawing.unlike(activeUser)
        myRootRef.child("drawings/\(drawing.id)/likes/\(activeUser.userId)").removeValue()
    }
    
    func reportDrawing(_ drawing: Drawing) {
        myRootRef.child("reported/drawings/\(drawing.id)/\(activeUser.userId)").setValue(0 - Date().timeIntervalSince1970)
    }

    func makeDOD(_ drawing: Drawing) {
        myRootRef.child("drawingOfTheDay").setValue(drawing.id)
    }

}
