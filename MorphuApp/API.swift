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
    
    let storage = FIRStorage.storage()
    let storageRef: FIRStorageReference
    
    private let facebookLogin = FBSDKLoginManager()

    private var wall = [Drawing]()
    private var users = [User]()
    private var activeUser: User?
    
    private var userDict = [String: User]()
    private var drawingDict = [String: Drawing]()
    private var imageDict = [String: UIImage]()
    
    private var oldestTimeLoaded: Double = -99999999999999
    private var newestTimeLoaded: Double = 0
    
    var delagate: APIDelagate?
    
    init() {
        self.storageRef = storage.referenceForURL("gs://project-3272790237826499087.appspot.com")
    }
    
    // MARK: Internal methods
    
    private func getDrawing(drawingId: String, callback: (Drawing, Bool) -> ()) { //callback
        if let drawing = self.drawingDict[drawingId] {
            callback(drawing, false)
        } else {
        
        self.myRootRef.child("drawings/\(drawingId)").observeSingleEventOfType(.Value, withBlock: {snapshot in
            if (!snapshot.exists()) { return }
            
            self.getUser(snapshot.value!["artist"] as! String, callback: { (artist: User) -> () in
                
                let drawing = Drawing(artist: artist, timeStamp: snapshot.value!["timeStamp"] as! Double, drawingId: drawingId)
                
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
                
                self.drawingDict[drawingId] = drawing
                
                callback(drawing, true)
            })
        })
        }
    }
    
    private func getComment(commentId: String, callback: (Comment) -> ()) {
        self.myRootRef.child("comments/\(commentId)").observeSingleEventOfType(.Value, withBlock: {snapshot in
            if (!snapshot.exists()) { return }
            
            let text = snapshot.value!["text"] as! String
            let timeStamp = snapshot.value!["timeStamp"] as! Double
            
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
                
//                self.getFullUser(newUser)
                
                self.userDict[userId] = newUser
                callback(newUser)
            })
        }
    }
    
    func getFullUser(user: User, delagate: APIDelagate?) {
        
        if !user.getfullUserLoaded() {
        self.myRootRef.child("users/\(user.userId)/following").observeEventType(.ChildAdded, withBlock: {snapshot in
            self.getUser(snapshot.key, callback: { (follow: User) -> () in
                user.follow(follow)
                self.myRootRef.child("users/\(follow.userId)/drawings").observeEventType(.ChildAdded, withBlock: {snapshot in
                    self.myRootRef.child("users/\(self.activeUser!.userId)/wall/\(snapshot.key)").setValue(snapshot.value)
                })
            })
        })
        
        self.myRootRef.child("users/\(user.userId)/following").observeEventType(.ChildRemoved, withBlock: {snapshot in
            self.getUser(snapshot.key, callback: { (unfollow: User) -> () in
                user.unfollow(unfollow)
                self.myRootRef.child("users/\(unfollow.userId)/drawings").observeEventType(.ChildAdded, withBlock: {snapshot in
                    self.myRootRef.child("users/\(self.activeUser!.userId)/wall/\(snapshot.key)").removeValue()
                })
            })
        })
        
        self.myRootRef.child("users/\(user.userId)/followers").observeEventType(.ChildAdded, withBlock: {snapshot in
            self.getUser(snapshot.key, callback: { (follower: User) -> () in
                user.addFollower(follower)
            })
        })
        
        self.myRootRef.child("users/\(user.userId)/followers").observeEventType(.ChildRemoved, withBlock: {snapshot in
            self.getUser(snapshot.key, callback: { (unfollower: User) -> () in
                user.removeFollower(unfollower)
            })
        })
        
        self.myRootRef.child("users/\(user.userId)/drawings").queryOrderedByValue().observeEventType(.ChildAdded, withBlock: {snapshot in
            self.getDrawing(snapshot.key, callback: { (drawing: Drawing, new: Bool) -> () in
                user.addDrawing(drawing)
            })
        })
            
        delagate?.refresh()
        user.setfullUserLoaded()
        }
    }
    
    // MARK: External Methods
    
    func checkLoggedIn(callback: (Bool)-> ()) {
        if let user = FIRAuth.auth()?.currentUser {
            
            
            myRootRef.child("users/\(user.uid)/email").setValue("testEmail")
            myRootRef.child("users/\(user.uid)/username").setValue(user.displayName!)
            myRootRef.child("users/\(user.uid)/photoURL").setValue(user.photoURL?.absoluteString)
            
            self.loadData(user)
//            self.getFBFriends()
//            self.getActiveFBID({ (FBID: String) -> () in
//                self.myRootRef.child("users/\(user.uid)/fbId").setValue(FBID)
//            })
            
            callback(true)
        } else {
            callback(false)
        }
    }
    
    func getFBFriends() {
        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "friends"], HTTPMethod: "GET")
        
        // Get request Of Friends
        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!,
            result:AnyObject!, error:NSError!) -> Void in
                
                if let error = error {
                    print(error.description)
                }
                let resultdict = result as! NSDictionary
                let data : NSArray = resultdict.objectForKey("data") as! NSArray
                print(data)
                for i in 0 ..< data.count {
                    let valueDict : NSDictionary = data[i] as! NSDictionary
                    let id = valueDict.objectForKey("id") as! String
                    print(id)
                    self.loadUserByFBID(id)
            }
        }
    }
    
    func getActiveFBID(callback: (String) -> ()) {
        let request = FBSDKGraphRequest(graphPath: "/me", parameters: nil, HTTPMethod: "GET")
        
        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!,
            result:AnyObject!, error:NSError!) -> Void in
            
            if let error = error {
                print(error.description)
            }
            let resultdict = result as! NSDictionary
            
            callback(resultdict.objectForKey("id") as! String)
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
                    if user != nil {
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
        self.drawingDict.removeAll()
        self.userDict.removeAll()
        self.imageDict.removeAll()
        self.activeUser = nil
        self.oldestTimeLoaded = -99999999999999
        self.newestTimeLoaded = 0
        
        self.myRootRef.removeAllObservers()
        try! FIRAuth.auth()!.signOut()
        FBSDKLoginManager().logOut()
    }

    
    func postDrawing(drawing: Drawing, progressCallback: (Float) -> (), finishedCallback: (Bool) -> ()) {
        let newDrawing = myRootRef.child("drawings").childByAutoId()
        drawing.setDrawingId(newDrawing.key)

        self.uploadImage(drawing, progressCallback: progressCallback, finishedCallback:  { uploaded in
            if uploaded {
                drawing.setArtist(self.activeUser!)
                newDrawing.setValue(drawing.toAnyObject())
                self.myRootRef.child("users/\(self.activeUser!.userId)/drawings/\(drawing.getDrawingId())").setValue(drawing.timeStamp)
                self.myRootRef.child("users/\(self.activeUser!.userId)/wall/\(drawing.getDrawingId())").setValue(drawing.timeStamp)
            }
            finishedCallback(uploaded)
        })
    }
    
    func deleteDrawing(drawing: Drawing) {
        myRootRef.child("drawings/\(drawing.getDrawingId())").removeValue()
        myRootRef.child("users/\(activeUser!.userId)/drawings/\(drawing.getDrawingId())").removeValue()
        myRootRef.child("users/\(activeUser!.userId)/wall/\(drawing.getDrawingId())").removeValue()
        
        let desertRef = storageRef.child("drawings/\(drawing.getDrawingId()).png")
        
        desertRef.deleteWithCompletion { (error) -> Void in
            if (error != nil) {
                print("File deletion error")
            } else {
                print("File deleted successfully")
            }
        }
        
        delagate?.refresh()
    }
    
    func like(drawing: Drawing) {
        drawing.like(self.activeUser!)
        myRootRef.child("drawings/\(drawing.getDrawingId())/likes/\(self.activeUser!.userId)").setValue(true)
    }
    
    func unlike(drawing: Drawing) {
        drawing.unlike(self.activeUser!)
        myRootRef.child("drawings/\(drawing.getDrawingId())/likes/\(self.activeUser!.userId)").removeValue()
    }
    
    func addComment(drawing: Drawing, text: String) {
        let comment = Comment(user: self.activeUser!, text: text)
        let newComment = myRootRef.child("comments").childByAutoId()

        comment.setCommentId(newComment.key)
        drawing.addComment(comment)
        newComment.setValue(comment.toAnyObject())
        myRootRef.child("drawings/\(drawing.getDrawingId())/comments/\(newComment.key)").setValue(true)
    }
    
    func follow(user: User) {
        myRootRef.child("users/\(activeUser!.userId)/following/\(user.userId)").setValue(true)
        myRootRef.child("users/\(user.userId)/followers/\(activeUser!.userId)").setValue(true)
    }
    
    func unfollow(user: User) {
        myRootRef.child("users/\(activeUser!.userId)/following/\(user.userId)").removeValue()
        myRootRef.child("users/\(user.userId)/followers/\(activeUser!.userId)").removeValue()
    }
    
    // MARK: Get Methods
    func getActiveUser() -> User {
        return self.activeUser!
    }
    
    func getWall() -> [Drawing] {
        return self.wall
    }
    
    func getUsers() -> [User] {
        return self.users
    }
    
    //MARK: Load Data
    
    private func loadData(user: FIRUser) {
        self.getUser(user.uid, callback: { (activeUser: User) -> () in
            self.activeUser = activeUser
//            self.getFullUser(self.activeUser!)
            self.loadWall()
            self.loadUsers(user)
        })
    }
    
//    private func addDrawings() {
//        myRootRef.child("drawings").queryOrderedByChild("artist").queryEqualToValue(self.activeUser?.userId).observeEventType(.ChildAdded, withBlock: { snapshot in
//            let drawingId = snapshot.key
//            let timeStamp = snapshot.value!["timeStamp"] as! Double
//            self.myRootRef.child("users/\(self.activeUser!.userId)/drawings/\(drawingId)").setValue(timeStamp)
//            self.myRootRef.child("users/\(self.activeUser!.userId)/wall/\(drawingId)").setValue(timeStamp)
//        })
//    }

    func loadWall() {
        myRootRef.child("users/\(getActiveUser().userId)/wall").queryOrderedByValue().queryLimitedToFirst(8).queryStartingAtValue(self.oldestTimeLoaded)
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                self.getDrawing(snapshot.key, callback: { (drawing: Drawing, new: Bool) -> () in
                    if self.wall.count == 0 {
                        self.wall.append(drawing)
                        self.oldestTimeLoaded = drawing.timeStamp
                        self.newestTimeLoaded = drawing.timeStamp
                        self.delagate?.refresh()
                    } else if drawing.timeStamp > self.oldestTimeLoaded {
                        self.oldestTimeLoaded = drawing.timeStamp
                        self.wall.append(drawing)
                    } else if drawing.timeStamp < self.newestTimeLoaded {
                        self.newestTimeLoaded = drawing.timeStamp
                        self.wall.insert(drawing, atIndex: 0)
                    } else {
                        if new {
                            var i = 0
                            for drawing_ in self.wall {
                                if drawing_.timeStamp > drawing.timeStamp {
                                    self.wall.insert(drawing, atIndex: i)
                                    return
                                }
                                i += 1
                            }
                        }
                    }
                })
            })
        
        myRootRef.child("users/\(getActiveUser().userId)/wall").observeEventType(.ChildRemoved, withBlock: { snapshot in
                let drawingId = snapshot.key
                var i = 0
                self.drawingDict[drawingId] = nil
                for drawing in self.wall {
                    if drawing.getDrawingId() == drawingId {
                        self.wall.removeAtIndex(i)
                        return
                    }
                    i += 1
                }
            })
        }
    
    private func loadUserByFBID(FBID: String) {
        print("loadUserByFBID \(FBID)")
        myRootRef.child("users").queryOrderedByChild("fbId").queryEqualToValue(FBID)
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                self.getUser(snapshot.key, callback: { (user: User) -> () in
                    
                    print("Add user \(user.username)")

                    self.users.append(user)
                })
            })
    }
    
    private func loadUsers(currentUser: FIRUser) {
        myRootRef.child("users").queryOrderedByKey()
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                let userId = snapshot.key
                self.getUser(snapshot.key, callback: { (user: User) -> () in
                    if !(userId == currentUser.uid) {
//                        self.getFullUser(user)
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
    
    func downloadImage(imageId: String, progressCallback: (Float) -> (), finishedCallback: (UIImage) -> ()) {
        if let image = imageDict[imageId] {
            finishedCallback(image)
        } else {
            let drawingRef = storageRef.child("drawings/\(imageId).png")
            
            let downloadTask = drawingRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                    print(error)
                    } else {
                    if let imageData = data {
                        progressCallback(1.0)
                        let image = UIImage(data: imageData)!
                        self.imageDict[imageId] = image
                        finishedCallback(image)
                    } else {
                        print("data error")
                    }
                }
            }
        
            downloadTask.observeStatus(.Progress) { (snapshot) -> Void in
                if let progress = snapshot.progress {
                    let percentComplete = 100.0 * Float(Double(progress.completedUnitCount) / Double(progress.totalUnitCount))
                    progressCallback(percentComplete)
                }
            }
        }
    }
    
    
    func uploadImage(drawing: Drawing, progressCallback: (Float) -> (), finishedCallback: (Bool) -> ()) {

        let uploadTask = storageRef.child("drawings/\(drawing.getDrawingId()).png").putData(UIImagePNGRepresentation(drawing.getImage())!)
    
        uploadTask.observeStatus(.Progress) { snapshot in
            // Upload reported progress
            if let progress = snapshot.progress {
                let percentComplete = Float(100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount))
                progressCallback(percentComplete)
            }
        }
        
        uploadTask.observeStatus(.Success) { snapshot in
            progressCallback(1.0)
            finishedCallback(true)
        }
    
        uploadTask.observeStatus(.Failure) { snapshot in
            finishedCallback(false)
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