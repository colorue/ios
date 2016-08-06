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
import Alamofire

class API {
    
    static let sharedInstance = API()

    private let myRootRef = FIRDatabase.database().reference()
    
    let storageRef = FIRStorage.storage().reference()
    
    var airshipKey = ""

    private var drawingOfTheDay = [Drawing]()
    private var wall = [Drawing]()
    private var facebookFriends = Set<User>()
    private var contacts = Set<User>()
    private var popularUsers = Set<User>()
    private var prompts = Set<Prompt>()

    private var activeUser: User?
    
    private var userDict = [String: User]()
    private var drawingDict = [String: Drawing]()
    private var imageDict = [String: UIImage]()
    
    private var oldestTimeLoaded: Double = -99999999999999
    private var oldestExploreLoaded: Double = -99999999999999
    private var newestTimeLoaded: Double = 0
    
    private lazy var contactStore = ContactStore()
    
    var delagate: APIDelagate?
    
    // MARK: Internal methods
    
    private func getDrawing(drawingId: String, callback: (Drawing, Bool) -> ()) { //callback
        if let drawing = self.drawingDict[drawingId] {
            callback(drawing, false)
        } else {
        
        self.myRootRef.child("drawings/\(drawingId)").observeSingleEventOfType(.Value, withBlock: {snapshot in
            if (!snapshot.exists()) { return }
            
            self.getUser(snapshot.value!["artist"] as! String, callback: { (artist: User) -> () in
                
                let drawing = Drawing(artist: artist, timeStamp: snapshot.value!["timeStamp"] as! Double, drawingId: drawingId)
                
                if let urlString = snapshot.value!["url"] as?  String {
                    drawing.url = NSURL(string: urlString)
                } else {
                    self.setDrawingURL(drawingId, callback: { url in
                        drawing.url = url
                    })
                }
                
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
            
                if let profileDrawing = snapshot.value!["photoURL"] as? String {
                    self.downloadImage(profileDrawing, progressCallback: nil, finishedCallback: { image in
                        newUser.profileImage = image
                    })
                }

                self.userDict[userId] = newUser
                callback(newUser)
            })
        }
    }
    
    func getFullActiveUser(user: User) {
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
            user.setfullUserLoaded()
        }
    }
    
    
    func loadFulUser(user: User) {
        if !user.getfullUserLoaded() {
            self.myRootRef.child("users/\(user.userId)/following").observeEventType(.ChildAdded, withBlock: {snapshot in
                self.getUser(snapshot.key, callback: { (follow: User) -> () in
                    user.follow(follow)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/following").observeEventType(.ChildRemoved, withBlock: {snapshot in
                self.getUser(snapshot.key, callback: { (unfollow: User) -> () in
                    user.unfollow(unfollow)
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
            
            self.myRootRef.child("users/\(user.userId)/followers").observeEventType(.ChildRemoved, withBlock: {snapshot in
                self.getDrawing(snapshot.key, callback: { (drawing: Drawing, new: Bool) -> () in
                    user.removeDrawing(drawing)
                })
            })
            user.setfullUserLoaded()
        }
    }
    
    // MARK: User Action Methods
    
    func postDrawing(drawing: Drawing, progressCallback: (Float) -> (), prompt: Prompt?, finishedCallback: (Bool) -> ()) {
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
                    
                    if let prompt = prompt {
                        self.myRootRef.child("prompts/\(prompt.getPromptId())/drawings/\(drawing.getDrawingId())").setValue(drawing.timeStamp)
                    }
                })
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
        self.myRootRef.child("users/\(self.getActiveUser().userId)/photoURL").setValue(drawing.getDrawingId())
        self.getActiveUser().profileImage = drawing.getImage()
        self.delagate?.refresh()
    }
    
    func like(drawing: Drawing) {
        drawing.like(self.activeUser!)
        myRootRef.child("drawings/\(drawing.getDrawingId())/likes/\(self.activeUser!.userId)").setValue(true)
        
        sendPushNotification("\(activeUser!.username) liked your drawing", recipient: drawing.getArtist().userId, badge: "+0")
    }
    
    func unlike(drawing: Drawing) {
        drawing.unlike(self.activeUser!)
        myRootRef.child("drawings/\(drawing.getDrawingId())/likes/\(self.activeUser!.userId)").removeValue()
    }
    
    func addComment(drawing: Drawing, text: String) {
        guard let activeUser = activeUser else { return }

        let comment = Comment(user: self.activeUser!, text: text)
        let newComment = myRootRef.child("comments").childByAutoId()

        comment.setCommentId(newComment.key)
        drawing.addComment(comment)
        newComment.setValue(comment.toAnyObject())
        myRootRef.child("drawings/\(drawing.getDrawingId())/comments/\(newComment.key)").setValue(true)
        
        sendPushNotification("\(activeUser.username) commented on your drawing", recipient: drawing.getArtist().userId, badge: "+0")
    }
    
    func createPrompt(text: String) {
        guard let activeUser = activeUser else { return }

        let prompt = Prompt(user: activeUser, text: text)
        let newPrompt = myRootRef.child("prompts").childByAutoId()
        
        prompt.setPromptId(newPrompt.key)
        prompts.insert(prompt)
        newPrompt.setValue(prompt.toAnyObject())
    }
    
    func deleteComment(drawing: Drawing, comment: Comment) {
        drawing.removeComment(comment)
        myRootRef.child("comments/\(comment.getCommetId())").removeValue()
        myRootRef.child("drawings/\(drawing.getDrawingId())/comments/\(comment.getCommetId())").removeValue()
    }
    
    func deletePrompt(prompt: Prompt) {
        prompts.remove(prompt)
        myRootRef.child("prompts/\(prompt.getPromptId())").removeValue()
    }
    
    func follow(user: User) {
        myRootRef.child("users/\(activeUser!.userId)/following/\(user.userId)").setValue(true)
        myRootRef.child("users/\(user.userId)/followers/\(activeUser!.userId)").setValue(true)
        sendPushNotification("\(activeUser!.username) is following you!", recipient: user.userId, badge: "+0")
    }
    
    func unfollow(user: User) {
        myRootRef.child("users/\(activeUser!.userId)/following/\(user.userId)").removeValue()
        myRootRef.child("users/\(user.userId)/followers/\(activeUser!.userId)").removeValue()
    }
    
    func searchUsers(search: String, callback: (User)->()) {
        let lowercase = search.lowercaseString
        let searchStart = lowercase
        let searchEnd = lowercase + "z"
        myRootRef.child("userLookup/usernames").removeAllObservers()
        myRootRef.child("userLookup/usernames").queryOrderedByKey()
            .queryStartingAtValue(searchStart)
            .queryEndingAtValue(searchEnd)
            .queryLimitedToFirst(16)
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                let userId = snapshot.value as! String
                self.getUser(userId, callback: { (user: User) -> () in
                    callback(user)
                })
            })
    }
    
    
    func reportDrawing(drawing: Drawing) {
        if let active = activeUser {
            myRootRef.child("reported/drawings/\(drawing.getDrawingId())/\(active.userId)").setValue(0 - NSDate().timeIntervalSince1970)
        }
    }
    
    func reportComment(comment: Comment) {
        if let active = activeUser {
            myRootRef.child("reported/comments/\(comment.getCommetId())/\(active.userId)").setValue(0 - NSDate().timeIntervalSince1970)
        }
    }
    
    func reportPrompt(prompt: Prompt) {
        if let active = activeUser {
            myRootRef.child("reported/prompts/\(prompt.getPromptId())/\(active.userId)").setValue(0 - NSDate().timeIntervalSince1970)
        }
    }
    
    func makeDOD(drawing: Drawing) {
        myRootRef.child("drawingOfTheDay").setValue(drawing.getDrawingId())
    }
    
    // MARK: Get Methods
    
    func getActiveUser() -> User {
        return self.activeUser!
    }
    
    func getDrawingOfTheDay() -> [Drawing] {
        return self.drawingOfTheDay
    }
    
    func getWall() -> [Drawing] {
        return self.wall
    }
    
    func getSuggustedUsers() -> [User] {
        return Array(self.popularUsers.union(self.facebookFriends))
    }
    
    func getFriends() -> [User] {
        return Array(facebookFriends.union(contacts))
    }
    
    func getContacts() -> [Contact] {
        return contactStore.getContacts().sort( { $0.name < $1.name } )
    }
    
    func getPrompts() -> [Prompt] {
        return prompts.sort( { $0.timeStamp < $1.timeStamp } )
    }
    
    //MARK: Load Data
    
    func loadData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let userId = FIRAuth.auth()!.currentUser!.uid
            self.getUser(userId, callback: { (activeUser: User) -> () in
                self.activeUser = activeUser
                self.getFullActiveUser(activeUser)
                self.loadDrawingOfTheDay()
                self.loadWall()
                self.setDeleteWall()
                self.loadPrompts()
                self.loadFacebookFriends()
                self.getAirshipKey()
            })
        })
    }
    
    func clearData() {
        self.facebookFriends.removeAll()
        self.wall.removeAll()
        self.drawingDict.removeAll()
        self.userDict.removeAll()
        self.imageDict.removeAll()
        self.activeUser = nil
        self.oldestExploreLoaded = -99999999999999
        self.oldestTimeLoaded = -99999999999999
        self.newestTimeLoaded = 0
    }
    
    func releaseMemory() {
        for drawing in wall {
            drawing.setImage(nil)
        }
        self.userDict.removeAll()
        self.drawingDict.removeAll()
        self.imageDict.removeAll()
    }

    // Used both for initial load and to add older drawings
    func loadWall() {
        myRootRef.child("users/\(getActiveUser().userId)/wall").queryOrderedByValue().queryLimitedToFirst(16).queryStartingAtValue(self.oldestTimeLoaded)
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                self.getDrawing(snapshot.key, callback: { (drawing: Drawing, new: Bool) -> () in
                    if self.wall.count == 0 {
                        self.wall.append(drawing)
                        self.oldestTimeLoaded = drawing.timeStamp
                        self.newestTimeLoaded = drawing.timeStamp
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
        
    }
    
    private func setDeleteWall() {
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
    
    private func loadPrompts() {
        myRootRef.child("prompts").observeEventType(.ChildAdded, withBlock: { snapshot in
            let promptId = snapshot.key
            
            let text = snapshot.value!["text"] as! String
            let timeStamp = snapshot.value!["timeStamp"] as! Double
            
            self.getUser(snapshot.value!["user"] as! String, callback: { (user: User) -> () in
                
                let prompt = Prompt(promptId: promptId, user: user, timeStamp: timeStamp, text: text)
                self.prompts.insert(prompt)
                
                self.myRootRef.child("prompts/\(promptId)/drawings").queryOrderedByValue().observeEventType(.ChildAdded, withBlock: {snapshot in
                    
                    self.getDrawing(snapshot.key, callback: { (drawing: Drawing, new: Bool) -> () in
                        prompt.drawings.append(drawing)
                    })
                })
            })
        })
    }

    func loadDrawingOfTheDay() {
        myRootRef.child("drawingOfTheDay").observeEventType(.Value, withBlock: { snapshot in
            guard snapshot.exists() else { return }
            self.getDrawing(snapshot.value as! String, callback: { (drawing: Drawing, new: Bool) -> () in
                self.drawingOfTheDay.removeAll()
                self.drawingOfTheDay.append(drawing)
                dispatch_async(dispatch_get_main_queue()) {
                    self.delagate!.refresh()
                }
            })
        })
    }
    
    func loadFacebookFriends() {
        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "friends"], HTTPMethod: "GET")
        
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
    
    private func loadUserByFBID(FBID: String) {
        myRootRef.child("userLookup/FacebookIDs/\(FBID)").observeEventType(.Value, withBlock: { snapshot in
            if !snapshot.exists() { return }
            let userID = snapshot.value as! String
            self.getUser(userID, callback: { (user: User) -> () in
                self.facebookFriends.insert(user)
            })
        })
    }
    
    func removeFBFriend(user: User) {
        self.facebookFriends.remove(user)
    }
    
    func loadPopularUsers() {
        myRootRef.child("popularUsers").observeEventType(.ChildAdded, withBlock: { snapshot in
            guard snapshot.exists() else { return }
            let userID = snapshot.key
            self.getUser(userID, callback: { (user: User) -> () in
                self.popularUsers.insert(user)
            })
        })
    }
    
    func checkNumber(number: String) {

        myRootRef.child("userLookup/phoneNumbers/\(number)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            guard snapshot.exists() else { return }
            
            let userID = snapshot.value as! String
            self.getUser(userID, callback: { (user: User) -> () in
                self.contacts.insert(user)
                self.delagate?.refresh()
            })
        })
    }
    
    
    private func getAirshipKey() {
        myRootRef.child("airshipKey").observeEventType(.Value, withBlock: { snapshot in
            guard snapshot.exists() else { return }
            let key = snapshot.value as! String
            self.airshipKey = key
        })
    }
    
    // MARK: Image Upload + Download Methods
    
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
    
    func downloadImage(imageId: String, progressCallback: ((Float) -> ())?, finishedCallback: (UIImage) -> ()) {
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
                        progressCallback?(1.0)
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
                    progressCallback?(percentComplete)
                }
            }
        }
    }
    
    func setDrawingURL(drawingId: String, callback: ((NSURL?)->())) {
        let drawingRef = storageRef.child("drawings/\(drawingId).png")
        
        drawingRef.downloadURLWithCompletion { (URL, error) -> Void in
            guard error == nil else { return }
            self.myRootRef.child("drawings/\(drawingId)/url").setValue(URL?.absoluteString)
            callback(URL)
        }
    }
    
    
    // MARK: Push Notifications
    func sendPushNotification(message: String, recipient: String, badge: String) {
    
        let iosData: NSDictionary = ["alert": message] //, "sound": "default", "badge": badge
        let notificationData: NSDictionary = ["ios": iosData]
        let namedUser: NSDictionary = ["named_user": recipient]
        
        //let audienceData: NSDictionary = ["OR": [iPhone6]]
        
        Alamofire.request(.POST, "https://go.urbanairship.com/api/push",
            headers:   ["Authorization" : self.airshipKey,
                "Accept" : "application/vnd.urbanairship+json; version=3",
                "Drawing-Type" : "application/json"],
            parameters: ["audience":namedUser, "notification":notificationData, "device_types":["ios"]],
            encoding: .JSON)
            .response { request, response, data, error in
                let dataString = NSString(data: data!, encoding:NSUTF8StringEncoding)
                print(dataString!)
            }
    }
    
 }