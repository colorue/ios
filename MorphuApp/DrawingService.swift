//
//  DrawingService.swift
//  Colorue
//
//  Created by Dylan Wight on 10/2/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
import Firebase
import RealmSwift
import Realm

struct DrawingService {
    let myRootRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference()

    let realm = try! Realm()
    
    let basePath = "drawings"

    func getDrawing(_ drawingId: String, callback: @escaping (Drawing, Bool) -> ()) {

        self.myRootRef.child("drawings/\(drawingId)").observeSingleEvent(of: .value, with: {snapshot in
            if (!snapshot.exists()) { return }

            guard let value = snapshot.value as? [String:AnyObject] else { return }

            API.sharedInstance.getUser(value["artist"] as! String, callback: { (artist: User) -> () in

                let drawing = Drawing(artist: artist, timeStamp: value["timeStamp"] as! Double, drawingId: drawingId)

                if let urlString = value["url"] as?  String {
                    drawing.url = URL(string: urlString)
                } else {
                    self.setDrawingURL(drawingId, callback: { url in
                        drawing.url = url
                    })
                }

                self.myRootRef.child("drawings/\(drawingId)/likes").observe(.childAdded, with: {snapshot in
                    self.getUser(snapshot.key, callback: { (liker: User) -> () in
                        drawing.like(liker)
                    })
                })

                self.myRootRef.child("drawings/\(drawingId)/likes").observe(.childRemoved, with: {snapshot in
                    self.getUser(snapshot.key, callback: { (unliker: User) -> () in
                        drawing.unlike(unliker)
                    })
                })

                self.myRootRef.child("drawings/\(drawingId)/comments").observe(.childAdded, with: {snapshot in
                    CommentService().get(id: snapshot.key, callback: { comment in
                        drawing.add(comment: comment)
                    })
                })

                self.drawingDict[drawingId] = drawing
                
                callback(drawing, true)
            })
        })
    }

    func postDrawing(_ drawing: Drawing, progressCallback: @escaping (Float) -> (), finishedCallback: @escaping (Bool) -> ()) {
        let newDrawing = myRootRef.child("drawings").childByAutoId()
        drawing.setDrawingId(newDrawing.key)
        
        self.uploadImage(drawing, progressCallback: progressCallback, finishedCallback:  { uploaded in
            if uploaded {
                drawing.setArtist(self.activeUser!)
                self.setDrawingURL(drawing.getDrawingId(), callback: { url in
                    drawing.url = url
                    newDrawing.setValue(drawing.toAnyObject())
                    self.myRootRef.child("users/\(self.activeUser!.userId)/drawings/\(drawing.getDrawingId())").setValue(drawing.timeStamp)
                    self.myRootRef.child("users/\(self.activeUser!.userId)/wall/\(drawing.getDrawingId())").setValue(drawing.timeStamp)

                })
            }
            finishedCallback(uploaded)
        })
    }
    
    func deleteDrawing(_ drawing: Drawing) {
        myRootRef.child("drawings/\(drawing.getDrawingId())").removeValue()
        myRootRef.child("users/\(activeUser!.userId)/drawings/\(drawing.getDrawingId())").removeValue()
        myRootRef.child("users/\(activeUser!.userId)/wall/\(drawing.getDrawingId())").removeValue()
        
        let desertRef = storageRef.child("drawings/\(drawing.getDrawingId()).png")
        
        desertRef.delete { (error) -> Void in
            if (error != nil) {
                print("File deletion error")
            } else {
                self.delagate?.refresh()
            }
        }
    }
    
    func makeProfilePic(_ drawing: Drawing) {
        guard let activeUser = activeUser else { return }
        
        myRootRef.child("users/\(activeUser.userId)/photoURL").setValue(drawing.getDrawingId())
        activeUser.profileImage = drawing.getImage()
        delagate?.refresh()
    }
    
    func like(_ drawing: Drawing) {
        drawing.like(self.activeUser!)
        myRootRef.child("drawings/\(drawing.getDrawingId())/likes/\(self.activeUser!.userId)").setValue(true)
        PushService().send(message: "\(activeUser!.username) liked your drawing", to: drawing.getArtist())
    }
    
    func unlike(_ drawing: Drawing) {
        drawing.unlike(self.activeUser!)
        myRootRef.child("drawings/\(drawing.getDrawingId())/likes/\(self.activeUser!.userId)").removeValue()
    }
}
