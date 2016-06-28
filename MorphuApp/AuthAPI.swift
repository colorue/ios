//
//  AuthAPI.swift
//  Colorue
//
//  Created by Dylan Wight on 6/18/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Firebase

import FBSDKCoreKit
import FBSDKLoginKit
import SinchVerification

class AuthAPI {
    
    // MARK: Properties

    static let sharedInstance = AuthAPI()
    
    private let myRootRef = FIRDatabase.database().reference()
    private let facebookLogin = FBSDKLoginManager()
    
    lazy var newUser = NewUser()
    
    // MARK: Login/Registration Methods
    
    func checkLoggedIn(callback: (Bool) -> ()) {
        
        print("checkLoggedIn")
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            self.myRootRef.child("users/\(userID)").observeEventType(.Value, withBlock: { snapshot in
                print("checkLoggedInExists")
                callback(snapshot.exists())
            })
        } else {
            callback(false)
        }
    }
    
    func connectWithFacebook(viewController: UIViewController, callback: (FacebookLoginResult, FIRUser?)  -> ()) {
        
        facebookLogin.logInWithReadPermissions(["email", "user_friends"], fromViewController: viewController, handler: {
            (facebookResult, facebookError) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
                callback(.Failed, nil)
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
                callback(.Failed, nil)
            } else {
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                        callback(.Failed, nil)
                    } else {
                        if let user = user {
                            self.myRootRef.child("users/\(user.uid)").observeSingleEventOfType(.Value, withBlock: {snapshot in
                                if (snapshot.exists()) {
                                    callback(.LoggedIn, user)
                                } else {
                                    self.newUser.userId = user.uid
                                    self.newUser.email = user.email
                                    self.newUser.fullName = user.displayName
                                    self.newUser.FacebookSignUp = true
                                    self.newUser.userRef = user
                                    
                                    self.getActiveFBID({ (FBID: String) -> () in
                                        self.newUser.FacebookID = FBID
                                        callback(.Registered, user)
                                    })
                                }
                            })
                        } else {
                            callback(.Failed, nil)
                        }
                    }
                }
            }
        })
    }
    
    func createEmailAccount(newUser: NewUser, callback: (Bool) -> ()) {
        FIRAuth.auth()?.createUserWithEmail(newUser.email!, password: newUser.password!) { (user, error) in
            if error == nil {
                newUser.userId = user!.uid
                self.addNewUserToDatabase(newUser)
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    func emailLogin(email: String, password: String, callback: (FIRUser?)-> ()) {
        FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
            if let error = error {
                print(error)
                callback(nil)
            } else {
                callback(user)
            }
        }
    }
    
    func addNewUserToDatabase(newUser: NewUser) {
        self.myRootRef.child("users/\(newUser.userId!)").setValue(newUser.toAnyObject())
        self.myRootRef.child("userLookup/usernames/\(newUser.username!)").setValue(newUser.userId!)
        
        if let phoneNumber = newUser.phoneNumber {
            self.myRootRef.child("userLookup/phoneNumbers/\(phoneNumber)").setValue(newUser.userId!)
        }
        
        if let FacebookID = newUser.FacebookID {
            self.myRootRef.child("userLookup/FacebookIDs/\(FacebookID)").setValue(newUser.userId!)
        }
    }
    
    func logout() {
        self.newUser = NewUser()
        self.myRootRef.removeAllObservers()
        try! FIRAuth.auth()!.signOut()
        FBSDKLoginManager().logOut()
    }
    
    
    // MARK: Username Methods
    
    func checkUsernameAvaliability(username: String, callback: (Bool) -> ()) {
        self.myRootRef.child("userLookup/usernames/\(username)").observeSingleEventOfType(.Value, withBlock: {snapshot in
            if (snapshot.exists()) {
                callback(false)
            } else {
                self.newUser.username = username
                self.myRootRef.child("userLookup/usernames/\(username)").setValue("hold")
                callback(true)
            }
        })
    }
    
    func releaseUsernameHold() {
        if let username = self.newUser.username {
            if username != "" {
                self.myRootRef.child("userLookup/usernames/\(username)").removeValue()
            }
            self.newUser.username = nil
        }
    }
    
    
    // MARK: Email/Phone Methods

    func callVerification(phoneNumber: String, callback: (Bool) -> ()) {
        let verification = CalloutVerification(applicationKey: "938e93e3-fab4-4ce4-97e1-3e463891326a", phoneNumber: phoneNumber)
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
    
    
    // MARK: Facebook Graph Methods
    
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
}