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

    private var production = false
    private var inbox = [Chain]()
    private var archive = [Chain]()
    private var users = [User]()
    private var activeUser = User()
//    private var urbanAirshipKey = ""
    
    var inboxBadge: UITabBarItem?
    
    init() {
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .MediumStyle
        dateFormatter.timeZone = NSTimeZone(abbreviation: "EST")  // CHECK IF THIS WORKED!!!
    }
    
    // MARK: Internal methods
    private func addContent(content: Content, chainId: String) -> FIRDatabaseReference {
        let newContent = myRootRef.child("content").childByAutoId()
        content.setContentId(newContent.key)
        content.setChainId(chainId)

        content.setAuthor(activeUser)
        // TODO fix timestamps print(FirebaseServerValue.timestamp())
        newContent.setValue(content.toAnyObject())
        return newContent
    }
    
    private func getContent(contentId: String, callback: (Content) -> ()) {
        self.myRootRef.child("content/\(contentId)").observeSingleEventOfType(.Value, withBlock: {snapshot in
            if (!snapshot.exists()) { return }
            
            self.getUser(snapshot.value!["author"] as! String, callback: { (author: User) -> () in
                callback(Content(author: author, timeSent: self.dateFormatter.dateFromString(snapshot.value!["timeSent"] as! String)!, isDrawing: snapshot.value!["isDrawing"] as! Bool, text: snapshot.value!["text"] as! String, chainId: snapshot.value!["chainId"] as! String, contentId: contentId))
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
        self.inbox.removeAll()
        self.archive.removeAll()
        self.users.removeAll()
        self.myRootRef.removeAllObservers()
        try! FIRAuth.auth()!.signOut()
        FBSDKLoginManager().logOut()
    }
    
    func createChain(content: Content, nextUser: User) {
            let newChain = myRootRef.child("chains").childByAutoId()
            self.addToChain(Chain(chainId: newChain.key), content: content, nextUser: nextUser)
    }
    
    func addToChain(chain: Chain, content: Content, nextUser: User) {
        let newContent = self.addContent(content, chainId: chain.chainId)                            // Create content
        myRootRef.child("chains/\(chain.chainId)/content/\(newContent.key)")
            .setValue(chain.getAllContent().count * -1)                                              // Add content to chain
        myRootRef.child("users/\(self.activeUser.userId)/inbox/\(chain.chainId)").removeValue()      // Remove chain from activeUser's inbox
        myRootRef.child("users/\(self.activeUser.userId)/archive/\(chain.chainId)").setValue(true)   // Add chain to activeUser's achive
        myRootRef.child("users/\(nextUser.userId)/inbox/\(chain.chainId)").setValue(true)            // Add chain to nextUser's inbox
        myRootRef.child("chains/\(chain.chainId)/nextUser").setValue(nextUser.userId)                //set nextUser

            /*
            if content.isDrawing {
                self.sendPushNotification("\(self.activeUser.username) sent you a drawing to describe", recipient: nextUser.userId, badge: "+1")
            } else {
                self.sendPushNotification("\(self.activeUser.username) sent you a prompt to draw", recipient: nextUser.userId, badge: "+1")
            }
            */
    }
    
    func finishChain(chain: Chain, content: Content) {
        let newContent = self.addContent(content, chainId: chain.chainId)                                           // Create content
        myRootRef.child("chains/\(chain.chainId)/content/\(newContent.key)")
                .setValue(chain.getAllContent().count * -1)                                                             // Add content to chain
        myRootRef.child("users/\(self.activeUser.userId)/inbox/\(chain.chainId)").removeValue()                // Remove chain from activeUser's inbox
        myRootRef.child("users/\(self.activeUser.userId)/archive/\(chain.chainId)").setValue(true)             // Add chain to activeUser's achive
    }
    
    // MARK: Get Methods
    func getActiveUser() -> User {
        return self.activeUser
    }
    
    func getInbox() -> [Chain] {
        return self.inbox.reverse()
    }
    
    func getArchive() -> [Chain] {
        return self.archive.reverse()
    }
    
    func getUsers() -> [User] {
        return self.users
    }
    
    //MARK: Load Data
    
    private func loadData(user: FIRUser) {
        self.getUser(user.uid, callback: { (activeUser: User) -> () in
            self.activeUser = activeUser
        })
        self.loadArchive(user)
        self.loadInbox(user)
        self.loadUsers(user)
    }
    
    private func loadArchive(currentUser: FIRUser) {
        myRootRef.child("users/\(currentUser.uid)/archive").queryOrderedByKey()
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                let chainId = snapshot.key
                
                print("chainId " + chainId)
                
                let newChain = Chain(chainId: chainId)
                self.myRootRef.child("chains/\(chainId)/content").queryOrderedByValue()
                    .observeEventType(.ChildAdded, withBlock: { snapshot in
                        let contentId = snapshot.key
                        self.getContent(contentId, callback: { (content: Content) -> () in
                            newChain.prependContent(content)
                        })
                    })
                
                self.myRootRef.child("chains/\(chainId)/nextUser").observeSingleEventOfType(.Value, withBlock: {snapshot in
                    if (!snapshot.exists()) { return }
                    self.getUser(snapshot.value as! String, callback: { (nextUser: User) -> () in
                        newChain.setNextUser(nextUser)
                    })
                })
                self.archive.append(newChain)
            })

        myRootRef.child("users/\(currentUser.uid)/archive").queryOrderedByKey()
            .observeEventType(.ChildRemoved, withBlock: { snapshot in
                let chainId = snapshot.key
                var i = 0
                for chain in self.archive {
                    if chain.chainId == chainId {
                        self.archive.removeAtIndex(i)
                    }
                    i += 1
                }
            })
    }
    
    private func loadInbox(currentUser: FIRUser) {
        myRootRef.child("users/\(currentUser.uid)/inbox").queryOrderedByKey()
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                let chainId = snapshot.key
                let newChain = Chain(chainId: chainId)
                self.myRootRef.child("chains/\(chainId)/content").queryOrderedByKey()
                    .observeEventType(.ChildAdded, withBlock: { snapshot in
                        let contentId = snapshot.key
                        self.getContent(contentId, callback: { (content: Content) -> () in
                            newChain.appendContent(content)
                        })
                    })
                self.inbox.append(newChain)
            })
        
        myRootRef.child("users/\(currentUser.uid)/inbox").queryOrderedByKey()
            .observeEventType(.ChildRemoved, withBlock: { snapshot in
                let chainId = snapshot.key
                var i = 0
                for chain in self.inbox {
                    if chain.chainId == chainId {
                        self.inbox.removeAtIndex(i)
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
                "Content-Type" : "application/json"],
            parameters: ["audience":iPhone6, "notification":notificationData, "device_types":["ios"]],
            encoding: .JSON)
            .response { request, response, data, error in
                let dataString = NSString(data: data!, encoding:NSUTF8StringEncoding)
                print(dataString!)
            }
    }
 */
}