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

// MARK: Onboarding Methods

class AuthAPI {
    
    static let sharedInstance = AuthAPI()
    
    private let myRootRef = FIRDatabase.database().reference()
    private let facebookLogin = FBSDKLoginManager()
    
    var usernameHold: String?
    lazy var newUser = NewUser()

    func createEmailAccount(newUser: NewUser, callback: (Bool) -> ()) {
        FIRAuth.auth()?.createUserWithEmail(newUser.email!, password: newUser.password!) { (user, error) in
            if error == nil {
                newUser.userId = user!.uid
                self.myRootRef.child("users/\(newUser.userId!)").setValue(newUser.toAnyObject())
                self.myRootRef.child("usernames/\(newUser.username!)").setValue(newUser.userId!)
                
                if let phoneNumber = newUser.phoneNumber {
                    self.myRootRef.child("phoneNumbers/\(phoneNumber)").setValue(newUser.userId!)
                }
                
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    func addNewUserToDatabase(newUser: NewUser) {
        self.myRootRef.child("users/\(newUser.userId!)").setValue(newUser.toAnyObject())
        self.myRootRef.child("usernames/\(newUser.username!)").setValue(newUser.userId!)
        
        if let phoneNumber = newUser.phoneNumber {
            self.myRootRef.child("phoneNumbers/\(phoneNumber)").setValue(newUser.userId!)
        }
        
//        self.getUser(newUser.userId!, callback: { active in
//            self.activeUser = active
//            self.loadData(newUser.userRer!)
//        })
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
//                                    self.loadData(user)
//                                    
//                                    // Set active user
//                                    self.getUser(user.uid, callback: { active in
//                                        self.activeUser = active
//                                    })
                                    
                                    callback(.LoggedIn, user)
                                } else {
                                    self.newUser.userId = user.uid
                                    self.newUser.email = user.email
                                    self.newUser.fullName = user.displayName
                                    self.newUser.FacebookSignUp = true
                                    
                                    self.newUser.userRer = user
                                    
                                    
                                    // not working
//                                    self.getActiveFBID({ (FBID: String) -> () in
//                                        self.newUser.FacebookID = FBID
//                                    })
                                    callback(.Registered, user)
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
    
    
    func checkLoggedIn() -> FIRUser? {
        return FIRAuth.auth()?.currentUser
    }
    
    func logout() {
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
                self.usernameHold = username
                self.myRootRef.child("usernames/\(username)").setValue("hold")
                callback(true)
            }
        })
    }
    
    func releaseUsernameHold() {
        if let username = self.usernameHold {
            self.myRootRef.child("usernames/\(username)").removeValue()
            self.usernameHold = nil
        }
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
}