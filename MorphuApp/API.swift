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
import SinchVerification

class API {
    
    static let sharedInstance = API()

    private let myRootRef = FIRDatabase.database().reference()
    
    let storage = FIRStorage.storage()
    let storageRef: FIRStorageReference
    
    private let facebookLogin = FBSDKLoginManager()

    private var wall = [Drawing]()
    private var users = [User]()
    private var facebookFriends = [User]()

    private var activeUser: User?
    
    private var userDict = [String: User]()
    private var drawingDict = [String: Drawing]()
    private var imageDict = [String: UIImage]()
    
    private var oldestTimeLoaded: Double = -99999999999999
    private var newestTimeLoaded: Double = 0
    
    var delagate: APIDelagate?
    
    init() {
        self.storageRef = storage.referenceForURL("gs://project-6663883006145995611.appspot.com")
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
                let fullname = snapshot.value!["fullName"] as! String
            
                let newUser = User(userId: userId, username: username, fullname: fullname, email: email)
            
                if let url = snapshot.value!["photoURL"] as? String {
                    dispatch_async(dispatch_get_main_queue()) {
                        let url = NSURL(string: url)
                        let data = NSData(contentsOfURL : url!)
                        if let data = data {
                            newUser.profileImage = UIImage(data: data)
                        }
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
    

    
    
    func getFBFriends() {
        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "friends"], HTTPMethod: "GET")
        
        // Get request Of Friends
        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!,
            result:AnyObject!, error:NSError!) -> Void in
                
                if let error = error {
                    print(error.description)
                    return
                } else {
                    let resultdict = result as! NSDictionary
                    let data : NSArray = resultdict.objectForKey("data") as! NSArray
                    for i in 0 ..< data.count {
                        let valueDict : NSDictionary = data[i] as! NSDictionary
                        let id = valueDict.objectForKey("id") as! String
                        self.loadUserByFBID(id)
                    }
                }
            }
    }
    
    func getActiveFBID(callback: (String) -> ()) {
        let request = FBSDKGraphRequest(graphPath: "/me", parameters: nil, HTTPMethod: "GET")
        
        request.startWithCompletionHandler { (connection:FBSDKGraphRequestConnection!,
            result:AnyObject!, error:NSError!) -> Void in
            
            if let error = error {
                print(error.description)
            } else {
                let resultdict = result as! NSDictionary
                callback(resultdict.objectForKey("id") as! String)
            }
        }
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
                self.delagate?.refresh()
            }
        }
    }
    
    func makeProfilePic(drawing: Drawing) {
        let drawingRef = storageRef.child("drawings/\(drawing.getDrawingId()).png")
        

        drawingRef.downloadURLWithCompletion { (URL, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                self.myRootRef.child("users/\(self.getActiveUser().userId)/photoURL").setValue(URL?.absoluteString)
                self.getActiveUser().profileImage = drawing.getImage()
                self.delagate?.refresh()
            }
        }

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
    
    func deleteComment(drawing: Drawing, comment: Comment) {
        drawing.removeComment(comment)
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
    
    func getFacebookFriends() -> [User] {
        return self.facebookFriends
    }
    
    //MARK: Load Data
    
    private func loadData(user: FIRUser) {
        self.getUser(user.uid, callback: { (activeUser: User) -> () in
            self.activeUser = activeUser
            self.getFullUser(activeUser, delagate: nil)
            self.loadWall()
            self.loadUsers(user)
            self.delagate?.refresh()
        })
    }

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
        myRootRef.child("users").queryOrderedByChild("fbId").queryEqualToValue(FBID)
            .observeSingleEventOfType(.ChildAdded, withBlock: { snapshot in
                self.getUser(snapshot.key, callback: { (user: User) -> () in
                    self.facebookFriends.append(user)
                    self.delagate?.refresh()
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
        
        self.delagate?.refresh()
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
    
    
    // MARK: Onboarding Methods
    
    lazy var newUser = NewUser()
    
    func createEmailAccount(newUser: NewUser, callback: (Bool) -> ()) {
        FIRAuth.auth()?.createUserWithEmail(newUser.email!, password: newUser.password!) { (user, error) in
            if error == nil {
                newUser.userId = user!.uid
                self.myRootRef.child("users/\(newUser.userId!)").setValue(newUser.toAnyObject())
                self.myRootRef.child("usernames/\(newUser.username!)").setValue(newUser.userId!)
                
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    func addNewUserToDatabase(newUser: NewUser) {
        self.loadData(newUser.userRer!)
        self.myRootRef.child("users/\(newUser.userId!)").setValue(newUser.toAnyObject())
        self.myRootRef.child("usernames/\(newUser.username!)").setValue(newUser.userId!)
    }
    
    func emailLogin(email: String, password: String, callback: (Bool)-> ()) {
        FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
            if error == nil {
                if let user = user {
                    self.loadData(user)
                    // Save password and email
                    callback(true)
                } else {
                    callback(false)
                }
            } else {
                callback(false)
            }
        }
    }
    
    func connectWithFacebook(viewController: UIViewController, callback: (FacebookLoginResult)  -> ()) {
        
        facebookLogin.logInWithReadPermissions(["email", "user_friends"], fromViewController: viewController, handler: {
            (facebookResult, facebookError) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
                callback(.Failed)
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
                callback(.Failed)
            } else {
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                
                FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                        callback(.Failed)
                    } else {
                        if let user = user {
                            
                            self.myRootRef.child("users/\(user.uid)").observeSingleEventOfType(.Value, withBlock: {snapshot in
                                if (snapshot.exists()) {
                                    self.loadData(user)
                                    callback(.LoggedIn)
                                } else {
                                    self.newUser.userId = user.uid
                                    self.newUser.email = user.email
                                    self.newUser.fullName = user.displayName
                                    self.newUser.FacebookSignUp = true
                                    
                                    self.newUser.userRer = user
                                    
                                    
                                    // not working
                                    self.getActiveFBID({ (FBID: String) -> () in
                                        self.newUser.FacebookID = FBID
                                    })
                                    callback(.Registered)
                                }
                            })
                        } else {
                            callback(.Failed)
                        }
                    }
                }
            }
        })
    }
    
    
    func checkLoggedIn(callback: (Bool)-> ()) {
        if let user = FIRAuth.auth()?.currentUser {
            
            
            self.loadData(user)
            self.getFBFriends()

            
            callback(true)
        } else {
            callback(false)
        }
    }
    
    func logout() {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(false, forKey: "loggedIn")
        self.facebookFriends.removeAll()
        self.users.removeAll()
        self.wall.removeAll()
        self.drawingDict.removeAll()
        self.userDict.removeAll()
        self.imageDict.removeAll()
        self.activeUser = nil
        self.oldestTimeLoaded = -99999999999999
        self.newestTimeLoaded = 0
        self.newUser = NewUser()
        
        self.myRootRef.removeAllObservers()
        try! FIRAuth.auth()!.signOut()
        FBSDKLoginManager().logOut()
    }
    
    func resetPasswordEmail(email: String, callback: (Bool) -> ()) {
        FIRAuth.auth()?.sendPasswordResetWithEmail(email) { error in
            if let error = error {
                print(error)
                callback(false)
            } else {
                callback(true)
            }
        }
    }
    
    func checkUsernameAvaliability(username: String, callback: (Bool) -> ()) {
        self.myRootRef.child("usernames/\(username)").observeSingleEventOfType(.Value, withBlock: {snapshot in
            if (snapshot.exists()) {
                callback(false)
            } else {
                callback(true)
            }
        })
    }
    
    func callVerification(phoneNumber: String, callback: (Bool) -> ()) {
        // Get user's current region by carrier info

        let verification = CalloutVerification(applicationKey: "938e93e3-fab4-4ce4-97e1-3e463891326a", phoneNumber: "+14135888889")
        verification.initiate({(valid, error) in
            if let error = error {
                print("verification error: \(error)")
                callback(false)
            } else if !valid {
                print("invalid verification")
                callback(false)
            } else {
                print("number verified")
                callback(true)
            }
        })
    }
    
    //            myRootRef.child("users/\(user.uid)/photoURL").setValue(user.photoURL?.absoluteString)



    
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