//
//  API.swift
//  Morphu
//
//  Created by Dylan Wight on 4/18/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

import Firebase

import FBSDKCoreKit
import FBSDKLoginKit

class API {
    
    static let sharedInstance = API()

    private let myRootRef = FIRDatabase.database().reference()
    private let facebookLogin = FBSDKLoginManager()
    let dateFormatter = NSDateFormatter()

    private var wall = [Drawing]()
    private var users = [User]()
    private var activeUser = User()
    
    var inboxBadge: UITabBarItem?
    
    init() {
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .MediumStyle
        dateFormatter.timeZone = NSTimeZone(abbreviation: "EST")  // CHECK IF THIS WORKED!!!
    }
    
    // MARK: Internal methods
    
    private func getDrawing(drawingId: String, callback: (Drawing) -> ()) {
        self.myRootRef.child("drawings/\(drawingId)").observeSingleEventOfType(.Value, withBlock: {snapshot in
            if (!snapshot.exists()) { return }
            
            self.getUser(snapshot.value!["artist"] as! String, callback: { (artist: User) -> () in
                
                let drawing = Drawing(artist: artist, timeSent: self.dateFormatter.dateFromString(snapshot.value!["timeSent"] as! String)!, text: snapshot.value!["text"] as! String, drawingId: drawingId)
                
                self.myRootRef.child("drawings/\(drawingId)/likes").observeEventType(.ChildAdded, withBlock: {snapshot in
                    self.getUser(snapshot.key, callback: { (liker: User) -> () in
                        drawing.like(liker)
                    })
                })
                
                self.myRootRef.child("drawings/\(drawingId)/likes").observeEventType(.ChildRemoved, withBlock: {snapshot in
                    self.getUser(snapshot.key, callback: { (unliker: User) -> () in
                        drawing.unlike(unliker)
                    })
                })
                
                callback(drawing)
            })
        })
    }
    
    private func getUser(userId: String, callback: (User) -> ()) {
        self.myRootRef.child("users/\(userId)").observeSingleEventOfType(.Value, withBlock: {snapshot in
            if (!snapshot.exists()) { return }
            
            let username = snapshot.value!["username"] as! String
            let email = snapshot.value!["email"] as! String
            
            let newUser = User(userId: userId, username: username, email: email)
            
            if let url = snapshot.value!["profileImageURL"] as? String {
                dispatch_async(dispatch_get_main_queue()) {
                    let url = NSURL(string: url)
                    let data = NSData(contentsOfURL: url!)
                    newUser.profileImage = UIImage(data: data!)!
                }
            }
            callback(newUser)
        })
    }
    
    // MARK: External Methods
    
    func checkLoggedIn(callback: (Bool)-> ()) {
        if let user = FIRAuth.auth()?.currentUser {
            self.loadData(user)
            callback(true)
        } else {
            callback(false)
        }
    }
    
    func connectWithFacebook(viewController: UIViewController, callback: (Bool)  -> ()) {
        
        facebookLogin.logInWithReadPermissions(["email", "user_friends"], fromViewController: viewController, handler: {
        (facebookResult, facebookError) -> Void in
    
        if facebookError != nil {
            print("Facebook login failed. Error \(facebookError)")
            callback(false)
        } else if facebookResult.isCancelled {
            print("Facebook login was cancelled.")
            callback(false)
        } else {
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in

                if error != nil {
                    print("Login failed. \(error)")
                    callback(false)
                } else {
                    if let user = user {
                        self.loadData(user)
                        callback(true)
                    } else {
                        callback(false)
                    }
                }
            }
            }
        })
    }
    
    func logout() {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(false, forKey: "loggedIn")
        self.users.removeAll()
        self.myRootRef.removeAllObservers()
        try! FIRAuth.auth()!.signOut()
        FBSDKLoginManager().logOut()
    }

    
    func postDrawing(drawing: Drawing) {
        let newDrawing = myRootRef.child("drawings").childByAutoId()
        drawing.setDrawingId(newDrawing.key)
        drawing.setArtist(activeUser)
        newDrawing.setValue(drawing.toAnyObject())
    }
    
    func like(drawing: Drawing) {
        myRootRef.child("drawings/\(drawing.getDrawingId())/likes/\(self.activeUser.userId)").setValue(true)
    }
    
    func unlike(drawing: Drawing) {
        myRootRef.child("drawings/\(drawing.getDrawingId())/likes/\(self.activeUser.userId)").removeValue()
    }
    
    // MARK: Get Methods
    func getActiveUser() -> User {
        return self.activeUser
    }
    
    func getWall() -> [Drawing] {
        return self.wall.reverse()
    }
    
    func getUsers() -> [User] {
        return self.users
    }
    
    //MARK: Load Data
    
    private func loadData(user: FIRUser) {
        self.getUser(user.uid, callback: { (activeUser: User) -> () in
            self.activeUser = activeUser
        })
        self.loadWall(user)
        self.loadUsers(user)
    }
    
    private func loadWall(currentUser: FIRUser) {
        myRootRef.child("drawings").queryOrderedByKey()
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                self.getDrawing(snapshot.key, callback: { (drawing: Drawing) -> () in
                    self.wall.append(drawing)
                })
            })
        
        myRootRef.child("drawings").queryOrderedByKey()
            .observeEventType(.ChildRemoved, withBlock: { snapshot in
                let drawingId = snapshot.key
                var i = 0
                for drawing in self.wall {
                    if drawing.getDrawingId() == drawingId {
                        self.users.removeAtIndex(i)
                    }
                    i += 1
                }
            })
    }
    
    private func loadUsers(currentUser: FIRUser) {
        myRootRef.child("users").queryOrderedByKey()
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                let userId = snapshot.key
                self.getUser(snapshot.key, callback: { (user: User) -> () in
                    if !(userId == currentUser.uid) {
                        self.users.append(user)
                    }
                })
            })
        
        myRootRef.child("users").queryOrderedByKey()
            .observeEventType(.ChildRemoved, withBlock: { snapshot in
                let userId = snapshot.key
                var i = 0
                for user in self.users {
                    if user.userId == userId {
                        self.users.removeAtIndex(i)
                    }
                    i += 1
                }
            })
    }
    /*
    
    // MARK: Push Notifications
    func sendPushNotification(message: String, recipient: String, badge: String) {

        let iosData: NSDictionary = ["alert": message, "sound": "default", "badge": badge]
        let notificationData: NSDictionary = ["ios": iosData]
        let iPhone6: NSDictionary = ["named_user": recipient]
        
        //let audienceData: NSDictionary = ["OR": [iPhone6]]
        
        Alamofire.request(.POST, "https://go.urbanairship.com/api/push",
            headers:   ["Authorization" : self.urbanAirshipKey,
                "Accept" : "application/vnd.urbanairship+json; version=3",
                "Drawing-Type" : "application/json"],
            parameters: ["audience":iPhone6, "notification":notificationData, "device_types":["ios"]],
            encoding: .JSON)
            .response { request, response, data, error in
                let dataString = NSString(data: data!, encoding:NSUTF8StringEncoding)
                print(dataString!)
            }
    }
 */
}