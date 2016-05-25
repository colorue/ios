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
    
    private var userDict = [String: User]()
    
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
                
                let drawing = Drawing(artist: artist, timeStamp: self.dateFormatter.dateFromString(snapshot.value!["timeSent"] as! String)!, text: snapshot.value!["text"] as! String, drawingId: drawingId)
                
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
                
                self.myRootRef.child("drawings/\(drawingId)/comments").observeEventType(.ChildAdded, withBlock: {snapshot in
                    self.getComment(snapshot.key, callback: { (comment: Comment) -> () in
                        drawing.addComment(comment)
                    })
                })
                
                callback(drawing)
            })
        })
    }
    
    private func getComment(commentId: String, callback: (Comment) -> ()) {
        self.myRootRef.child("comments/\(commentId)").observeSingleEventOfType(.Value, withBlock: {snapshot in
            if (!snapshot.exists()) { return }
            
            let text = snapshot.value!["text"] as! String
            let timeStamp = self.dateFormatter.dateFromString(snapshot.value!["timeStamp"] as! String)!
            
            self.getUser(snapshot.value!["user"] as! String, callback: { (user: User) -> () in
                callback(Comment(commentId: commentId, user: user, timeStamp: timeStamp, text: text))
            })
        })

    }
    
    private func getUser(userId: String, callback: (User) -> ()) {
        if let user = self.userDict[userId] {
            callback(user)
        } else {
            self.myRootRef.child("users/\(userId)").observeSingleEventOfType(.Value, withBlock: {snapshot in
                if (!snapshot.exists()) { return }
            
                let username = snapshot.value!["username"] as! String
                let email = snapshot.value!["email"] as! String
            
                let newUser = User(userId: userId, username: username, email: email)
            
                if let url = snapshot.value!["photoURL"] as? String {
                    dispatch_async(dispatch_get_main_queue()) {
                        let url = NSURL(string: url)
                        let data = NSData(contentsOfURL: url!)
                        newUser.profileImage = UIImage(data: data!)!
                    }
                }
                self.userDict[userId] = newUser
                callback(newUser)
            })
        }
    }
    
    // MARK: External Methods
    
    func checkLoggedIn(callback: (Bool)-> ()) {
        if let user = FIRAuth.auth()?.currentUser {
            
            myRootRef.child("users/\(user.uid)/email").setValue("testEmail")
            myRootRef.child("users/\(user.uid)/username").setValue(user.displayName!)
            myRootRef.child("users/\(user.uid)/photoURL").setValue(user.photoURL?.absoluteString)

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
        self.wall.removeAll()
        self.myRootRef.removeAllObservers()
        try! FIRAuth.auth()!.signOut()
        FBSDKLoginManager().logOut()
    }

    
    func postDrawing(drawing: Drawing) {
        let newDrawing = myRootRef.child("drawings").childByAutoId()
        drawing.setDrawingId(newDrawing.key)
        drawing.setArtist(activeUser)
        newDrawing.setValue(drawing.toAnyObject())
        
        self.uploadImage(UIImage.fromBase64(drawing.text))
    }
    
    func like(drawing: Drawing) {
        drawing.like(self.activeUser)
        myRootRef.child("drawings/\(drawing.getDrawingId())/likes/\(self.activeUser.userId)").setValue(true)
    }
    
    func unlike(drawing: Drawing) {
        drawing.unlike(self.activeUser)
        myRootRef.child("drawings/\(drawing.getDrawingId())/likes/\(self.activeUser.userId)").removeValue()
    }
    
    func addComment(drawing: Drawing, text: String) {
        let comment = Comment(user: self.activeUser, text: text)
        let newComment = myRootRef.child("comments").childByAutoId()
        comment.setCommentId(newComment.key)
        drawing.addComment(comment)
        newComment.setValue(comment.toAnyObject())
        myRootRef.child("drawings/\(drawing.getDrawingId())/comments/\(newComment.key)").setValue(true)
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
    
    
    func uploadImage(image: UIImage) {
    
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("gs://project-3272790237826499087.appspot.com")
    
    // Upload file and metadata to the object 'images/mountains.jpg'
    let uploadTask = storageRef.child("images/mountains.jpg").putData(UIImagePNGRepresentation(image)!)
    
    // Listen for state changes, errors, and completion of the upload.
    uploadTask.observeStatus(.Pause) { snapshot in
    // Upload paused
    }
    
    uploadTask.observeStatus(.Resume) { snapshot in
    // Upload resumed, also fires when the upload starts
    }
    
    uploadTask.observeStatus(.Progress) { snapshot in
    // Upload reported progress
    if let progress = snapshot.progress {
        let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
    }
    }
    
    uploadTask.observeStatus(.Success) { snapshot in
    // Upload completed successfully
    }
    
    // Errors only occur in the "Failure" case
    uploadTask.observeStatus(.Failure) { snapshot in
    guard let storageError = snapshot.error else { return }
    guard let errorCode = FIRStorageErrorCode(rawValue: storageError.code) else { return }
        /*
    switch errorCode {
        case .ObjectNotFound: break
        // File doesn't exist
    
        case .Unauthorized: break
        // User doesn't have permission to access file
    
        case .Cancelled: break
        // User canceled the upload
    
    
        case .Unknown: break
        // Unknown error occurred, inspect the server response
        
    }
    */
    }
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