//
//  API.swift
//  Colorue
//
//  Created by Dylan Wight on 4/18/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
//import SinchVerification
import Alamofire

protocol APIDelagate {
    func refresh()
}

class API {
    
    static let sharedInstance = API()

    fileprivate let myRootRef = FIRDatabase.database().reference()
    
    let storageRef = FIRStorage.storage().reference()
    
    var airshipKey = ""

    fileprivate var drawingOfTheDay = [Drawing]()
    fileprivate var wall = [Drawing]()
    fileprivate var facebookFriends = Set<User>()
    fileprivate var contacts = Set<User>()
    fileprivate var popularUsers = Set<User>()
    fileprivate var prompts = Set<Prompt>()

    fileprivate var activeUser: User?
    
    fileprivate var userDict = [String: User]()
    fileprivate var drawingDict = [String: Drawing]()
    fileprivate var imageDict = [String: UIImage]()
    
    fileprivate var oldestTimeLoaded: Double = -99999999999999
    fileprivate var oldestExploreLoaded: Double = -99999999999999
    fileprivate var newestTimeLoaded: Double = 0
    
    fileprivate lazy var contactStore = ContactStore()
    
    var delagate: APIDelagate?
    
    // MARK: Internal methods
    
    fileprivate func getDrawing(_ drawingId: String, callback: @escaping (Drawing, Bool) -> ()) { //callback
        if let drawing = self.drawingDict[drawingId] {
            callback(drawing, false)
        } else {
        
        self.myRootRef.child("drawings/\(drawingId)").observeSingleEvent(of: .value, with: {snapshot in
            if (!snapshot.exists()) { return }
            
            guard let value = snapshot.value as? [String:AnyObject] else { return }
            
            self.getUser(value["artist"] as! String, callback: { (artist: User) -> () in
                
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
    
    fileprivate func getComment(_ commentId: String, callback: @escaping (Comment) -> ()) {
        self.myRootRef.child("comments/\(commentId)").observeSingleEvent(of: .value, with: {snapshot in
            if (!snapshot.exists()) { return }
            
            guard let value = snapshot.value as? [String : AnyObject] else { return }
            
            let text = value["text"] as! String
            let timeStamp = value["timeStamp"] as! Double
            
            self.getUser(value["user"] as! String, callback: { (user: User) -> () in
                callback(Comment(commentId: commentId, user: user, timeStamp: timeStamp, text: text))
            })
        })
    }
    
    fileprivate func getUser(_ userId: String, callback: @escaping (User) -> ()) {
        if let user = self.userDict[userId] {
            callback(user)
        } else {
            self.myRootRef.child("users/\(userId)").observeSingleEvent(of: .value, with: {snapshot in
                if (!snapshot.exists()) { return }
            
                guard let value = snapshot.value as? [String : AnyObject] else { return }
                
                let username = value["username"] as! String
                let email = value["email"] as! String
                let fullname = value["fullName"] as! String
            
                let newUser = User(userId: userId, email: email, username: username, fullname: fullname)
            
                if let profileDrawing = value["photoURL"] as? String {
                    self.downloadImage(profileDrawing, progressCallback: nil, finishedCallback: { image in
                        newUser.profileImage = image
                    })
                }

                self.userDict[userId] = newUser
                callback(newUser)
            })
        }
    }
    
    func getFullActiveUser(_ user: User) {
        if !user.getfullUserLoaded() {
            self.myRootRef.child("users/\(user.userId)/following").observe(.childAdded, with: {snapshot in
                self.getUser(snapshot.key, callback: { (follow: User) -> () in
                    user.follow(follow)
                    self.myRootRef.child("users/\(follow.userId)/drawings").observe(.childAdded, with: {snapshot in
                        self.myRootRef.child("users/\(self.activeUser!.userId)/wall/\(snapshot.key)").setValue(snapshot.value)
                    })
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/following").observe(.childRemoved, with: {snapshot in
                self.getUser(snapshot.key, callback: { (unfollow: User) -> () in
                    user.unfollow(unfollow)
                    self.myRootRef.child("users/\(unfollow.userId)/drawings").observe(.childAdded, with: {snapshot in
                        self.myRootRef.child("users/\(self.activeUser!.userId)/wall/\(snapshot.key)").removeValue()
                    })
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/followers").observe(.childAdded, with: {snapshot in
                self.getUser(snapshot.key, callback: { (follower: User) -> () in
                    user.addFollower(follower)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/followers").observe(.childRemoved, with: {snapshot in
                self.getUser(snapshot.key, callback: { (unfollower: User) -> () in
                    user.removeFollower(unfollower)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/drawings").queryOrderedByValue().observe(.childAdded, with: {snapshot in
                self.getDrawing(snapshot.key, callback: { (drawing: Drawing, new: Bool) -> () in
                    user.addDrawing(drawing)
                })
            })
            user.setfullUserLoaded()
        }
    }
    
    
    func loadFulUser(_ user: User) {
        if !user.getfullUserLoaded() {
            self.myRootRef.child("users/\(user.userId)/following").observe(.childAdded, with: {snapshot in
                self.getUser(snapshot.key, callback: { (follow: User) -> () in
                    user.follow(follow)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/following").observe(.childRemoved, with: {snapshot in
                self.getUser(snapshot.key, callback: { (unfollow: User) -> () in
                    user.unfollow(unfollow)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/followers").observe(.childAdded, with: {snapshot in
                self.getUser(snapshot.key, callback: { (follower: User) -> () in
                    user.addFollower(follower)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/followers").observe(.childRemoved, with: {snapshot in
                self.getUser(snapshot.key, callback: { (unfollower: User) -> () in
                    user.removeFollower(unfollower)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/drawings").queryOrderedByValue().observe(.childAdded, with: {snapshot in
                self.getDrawing(snapshot.key, callback: { (drawing: Drawing, new: Bool) -> () in
                    user.addDrawing(drawing)
                })
            })
            
            self.myRootRef.child("users/\(user.userId)/followers").observe(.childRemoved, with: {snapshot in
                self.getDrawing(snapshot.key, callback: { (drawing: Drawing, new: Bool) -> () in
                    user.removeDrawing(drawing)
                })
            })
            user.setfullUserLoaded()
        }
    }
    
    // MARK: User Action Methods
    
    func postDrawing(_ drawing: Drawing, progressCallback: @escaping (Float) -> (), prompt: Prompt?, finishedCallback: @escaping (Bool) -> ()) {
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
        self.myRootRef.child("users/\(self.getActiveUser().userId)/photoURL").setValue(drawing.getDrawingId())
        self.getActiveUser().profileImage = drawing.getImage()
        self.delagate?.refresh()
    }
    
    func like(_ drawing: Drawing) {
        drawing.like(self.activeUser!)
        myRootRef.child("drawings/\(drawing.getDrawingId())/likes/\(self.activeUser!.userId)").setValue(true)
        
        sendPushNotification("\(activeUser!.username) liked your drawing", recipient: drawing.getArtist().userId, badge: "+0")
    }
    
    func unlike(_ drawing: Drawing) {
        drawing.unlike(self.activeUser!)
        myRootRef.child("drawings/\(drawing.getDrawingId())/likes/\(self.activeUser!.userId)").removeValue()
    }
    
    func addComment(_ drawing: Drawing, text: String) {
        guard let activeUser = activeUser else { return }

        let comment = Comment(user: self.activeUser!, text: text)
        let newComment = myRootRef.child("comments").childByAutoId()

        comment.setCommentId(newComment.key)
        drawing.addComment(comment)
        newComment.setValue(comment.toAnyObject())
        myRootRef.child("drawings/\(drawing.getDrawingId())/comments/\(newComment.key)").setValue(true)
        
        sendPushNotification("\(activeUser.username) commented on your drawing", recipient: drawing.getArtist().userId, badge: "+0")
    }
    
    func createPrompt(_ text: String) {
        guard let activeUser = activeUser else { return }

        let prompt = Prompt(user: activeUser, text: text)
        let newPrompt = myRootRef.child("prompts").childByAutoId()
        
        prompt.setPromptId(newPrompt.key)
        prompts.insert(prompt)
        newPrompt.setValue(prompt.toAnyObject())
    }
    
    func deleteComment(_ drawing: Drawing, comment: Comment) {
        drawing.removeComment(comment)
        myRootRef.child("comments/\(comment.getCommetId())").removeValue()
        myRootRef.child("drawings/\(drawing.getDrawingId())/comments/\(comment.getCommetId())").removeValue()
    }
    
    func deletePrompt(_ prompt: Prompt) {
        prompts.remove(prompt)
        myRootRef.child("prompts/\(prompt.getPromptId())").removeValue()
    }
    
    func follow(_ user: User) {
        myRootRef.child("users/\(activeUser!.userId)/following/\(user.userId)").setValue(true)
        myRootRef.child("users/\(user.userId)/followers/\(activeUser!.userId)").setValue(true)
        sendPushNotification("\(activeUser!.username) is following you!", recipient: user.userId, badge: "+0")
    }
    
    func unfollow(_ user: User) {
        myRootRef.child("users/\(activeUser!.userId)/following/\(user.userId)").removeValue()
        myRootRef.child("users/\(user.userId)/followers/\(activeUser!.userId)").removeValue()
    }
    
    func searchUsers(_ search: String, callback: @escaping (User)->()) {
        let lowercase = search.lowercased()
        let searchStart = lowercase
        let searchEnd = lowercase + "z"
        myRootRef.child("userLookup/usernames").removeAllObservers()
        myRootRef.child("userLookup/usernames").queryOrderedByKey()
            .queryStarting(atValue: searchStart)
            .queryEnding(atValue: searchEnd)
            .queryLimited(toFirst: 16)
            .observe(.childAdded, with: { snapshot in
                let userId = snapshot.value as! String
                self.getUser(userId, callback: { (user: User) -> () in
                    callback(user)
                })
            })
    }
    
    
    func reportDrawing(_ drawing: Drawing) {
        if let active = activeUser {
            myRootRef.child("reported/drawings/\(drawing.getDrawingId())/\(active.userId)").setValue(0 - Date().timeIntervalSince1970)
        }
    }
    
    func reportComment(_ comment: Comment) {
        if let active = activeUser {
            myRootRef.child("reported/comments/\(comment.getCommetId())/\(active.userId)").setValue(0 - Date().timeIntervalSince1970)
        }
    }
    
    func reportPrompt(_ prompt: Prompt) {
        if let active = activeUser {
            myRootRef.child("reported/prompts/\(prompt.getPromptId())/\(active.userId)").setValue(0 - Date().timeIntervalSince1970)
        }
    }
    
    func makeDOD(_ drawing: Drawing) {
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
        return contactStore.getContacts().sorted( by: { $0.name < $1.name } )
    }
    
    func getPrompts() -> [Prompt] {
        return prompts.sorted( by: { $0.timeStamp < $1.timeStamp } )
    }
    
    //MARK: Load Data
    
    func loadData() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
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
        myRootRef.child("users/\(getActiveUser().userId)/wall").queryOrderedByValue().queryLimited(toFirst: 16).queryStarting(atValue: self.oldestTimeLoaded)
            .observe(.childAdded, with: { snapshot in
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
                        self.wall.insert(drawing, at: 0)
                    } else {
                        if new {
                            var i = 0
                            for drawing_ in self.wall {
                                if drawing_.timeStamp > drawing.timeStamp {
                                    self.wall.insert(drawing, at: i)
                                    return
                                }
                                i += 1
                            }
                        }
                    }
                })
            })
        
    }
    
    fileprivate func setDeleteWall() {
        myRootRef.child("users/\(getActiveUser().userId)/wall").observe(.childRemoved, with: { snapshot in
                let drawingId = snapshot.key
                var i = 0
                self.drawingDict[drawingId] = nil
                for drawing in self.wall {
                    if drawing.getDrawingId() == drawingId {
                        self.wall.remove(at: i)
                        return
                    }
                    i += 1
                }
            })
        }
    
    fileprivate func loadPrompts() {
        myRootRef.child("prompts").observe(.childAdded, with: { snapshot in
            let promptId = snapshot.key
            
            let text = snapshot.value!["text"] as! String
            let timeStamp = snapshot.value!["timeStamp"] as! Double
            
            self.getUser(snapshot.value!["user"] as! String, callback: { (user: User) -> () in
                
                let prompt = Prompt(promptId: promptId, user: user, timeStamp: timeStamp, text: text)
                self.prompts.insert(prompt)
                
                self.myRootRef.child("prompts/\(promptId)/drawings").queryOrderedByValue().observe(.childAdded, with: {snapshot in
                    
                    self.getDrawing(snapshot.key, callback: { (drawing: Drawing, new: Bool) -> () in
                        prompt.drawings.append(drawing)
                    })
                })
            })
        })
    }

    func loadDrawingOfTheDay() {
        myRootRef.child("drawingOfTheDay").observe(.value, with: { snapshot in
            guard snapshot.exists() else { return }
            self.getDrawing(snapshot.value as! String, callback: { (drawing: Drawing, new: Bool) -> () in
                self.drawingOfTheDay.removeAll()
                self.drawingOfTheDay.append(drawing)
                DispatchQueue.main.async {
                    self.delagate!.refresh()
                }
            })
        })
    }
    
    func loadFacebookFriends() {
        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "friends"], httpMethod: "GET")
        
        request?.start { (connection:FBSDKGraphRequestConnection!,
            result:AnyObject!, error:NSError!) -> Void in
            
            if let error = error {
                print(error.description)
                return
            } else {
                let resultdict = result as! NSDictionary
                let data : NSArray = resultdict.object(forKey: "data") as! NSArray
                for i in 0 ..< data.count {
                    let valueDict : NSDictionary = data[i] as! NSDictionary
                    let id = valueDict.object(forKey: "id") as! String
                    self.loadUserByFBID(id)
                }
            }
        }
    }
    
    fileprivate func loadUserByFBID(_ FBID: String) {
        myRootRef.child("userLookup/FacebookIDs/\(FBID)").observe(.value, with: { snapshot in
            if !snapshot.exists() { return }
            let userID = snapshot.value as! String
            self.getUser(userID, callback: { (user: User) -> () in
                self.facebookFriends.insert(user)
            })
        })
    }
    
    func removeFBFriend(_ user: User) {
        self.facebookFriends.remove(user)
    }
    
    func loadPopularUsers() {
        myRootRef.child("popularUsers").observe(.childAdded, with: { snapshot in
            guard snapshot.exists() else { return }
            let userID = snapshot.key
            self.getUser(userID, callback: { (user: User) -> () in
                self.popularUsers.insert(user)
            })
        })
    }
    
    func checkNumber(_ number: String) {

        myRootRef.child("userLookup/phoneNumbers/\(number)").observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists() else { return }
            
            let userID = snapshot.value as! String
            self.getUser(userID, callback: { (user: User) -> () in
                self.contacts.insert(user)
                self.delagate?.refresh()
            })
        })
    }
    
    
    fileprivate func getAirshipKey() {
        myRootRef.child("airshipKey").observe(.value, with: { snapshot in
            guard snapshot.exists() else { return }
            let key = snapshot.value as! String
            self.airshipKey = key
        })
    }
    
    // MARK: Image Upload + Download Methods
    
    func uploadImage(_ drawing: Drawing, progressCallback: @escaping (Float) -> (), finishedCallback: @escaping (Bool) -> ()) {
        
        let uploadTask = storageRef.child("drawings/\(drawing.getDrawingId()).png").put(UIImagePNGRepresentation(drawing.getImage())!)
        
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            if let progress = snapshot.progress {
                let percentComplete = Float(100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount))
                progressCallback(percentComplete)
            }
        }
        
        uploadTask.observe(.success) { snapshot in
            progressCallback(1.0)
            finishedCallback(true)
        }
        
        uploadTask.observe(.failure) { snapshot in
            finishedCallback(false)
        }
    }
    
    func downloadImage(_ imageId: String, progressCallback: ((Float) -> ())?, finishedCallback: @escaping (UIImage) -> ()) {
        if let image = imageDict[imageId] {
            finishedCallback(image)
        } else {
            let drawingRef = storageRef.child("drawings/\(imageId).png")
            
            let downloadTask = drawingRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
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
        
            downloadTask.observe(.progress) { (snapshot) -> Void in
                if let progress = snapshot.progress {
                    let percentComplete = 100.0 * Float(Double(progress.completedUnitCount) / Double(progress.totalUnitCount))
                    progressCallback?(percentComplete)
                }
            }
        }
    }
    
    func setDrawingURL(_ drawingId: String, callback: @escaping ((URL?)->())) {
        let drawingRef = storageRef.child("drawings/\(drawingId).png")
        
        drawingRef.downloadURL { (URL, error) -> Void in
            guard error == nil else { return }
            self.myRootRef.child("drawings/\(drawingId)/url").setValue(URL?.absoluteString)
            callback(URL)
        }
    }
    
    
    // MARK: Push Notifications
    func sendPushNotification(_ message: String, recipient: String, badge: String) {
    
        let iosData: NSDictionary = ["alert": message] //, "sound": "default", "badge": badge
        let notificationData: NSDictionary = ["ios": iosData]
        let namedUser: NSDictionary = ["named_user": recipient]
        
        //let audienceData: NSDictionary = ["OR": [iPhone6]]
        
        Alamofire.request(.POST, "https://go.urbanairship.com/api/push",
            headers:   ["Authorization" : self.airshipKey,
                "Accept" : "application/vnd.urbanairship+json; version=3",
                "Drawing-Type" : "application/json"],
            parameters: ["audience":namedUser, "notification":notificationData, "device_types":["ios"]],
            encoding: .json)
            .response { request, response, data, error in
                let dataString = NSString(data: data!, encoding:String.Encoding.utf8)
                print(dataString!)
            }
    }
    
 }
