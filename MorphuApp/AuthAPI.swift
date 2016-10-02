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
//import SinchVerification

enum FacebookLoginResult {
    case failed
    case registered
    case loggedIn
}

class AuthAPI {
    
    // MARK: Properties

    static let sharedInstance = AuthAPI()
    
    fileprivate let myRootRef = FIRDatabase.database().reference()
    fileprivate let facebookLogin = FBSDKLoginManager()
    
    lazy var newUser = NewUser()
    
    // MARK: Login/Registration Methods
    
    func checkLoggedIn(_ callback: @escaping (Bool) -> ()) {
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            self.myRootRef.child("users/\(userID)").observe(.value, with: { snapshot in
                
                callback(snapshot.exists())
            })
        } else {
            callback(false)
        }
    }
    
    func connectWithFacebook(_ viewController: UIViewController, callback: @escaping (FacebookLoginResult, FIRUser?)  -> ()) {
        
        facebookLogin.logIn(withReadPermissions: ["email", "user_friends"], from: viewController, handler: {
            (facebookResult, facebookError) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
                callback(.failed, nil)
            } else if (facebookResult?.isCancelled)! {
                print("Facebook login was cancelled.")
                callback(.failed, nil)
            } else {
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                        callback(.failed, nil)
                    } else {
                        if let user = user {
                            self.myRootRef.child("users/\(user.uid)").observeSingleEvent(of: .value, with: {snapshot in
                                if (snapshot.exists()) {
                                    callback(.loggedIn, user)
                                } else {
                                    self.newUser.userId = user.uid
                                    self.newUser.email = user.email
                                    self.newUser.fullName = user.displayName
                                    self.newUser.FacebookSignUp = true
                                    self.newUser.userRef = user
                                    
                                    self.getActiveFBID({ (FBID: String) -> () in
                                        self.newUser.FacebookID = FBID
                                        callback(.registered, user)
                                    })
                                }
                            })
                        } else {
                            callback(.failed, nil)
                        }
                    }
                }
            }
        })
    }
    
    func createEmailAccount(_ newUser: NewUser, callback: @escaping (Bool) -> ()) {
        FIRAuth.auth()?.createUser(withEmail: newUser.email!, password: newUser.password!) { (user, error) in
            if error == nil {
                newUser.userId = user!.uid
                self.addNewUserToDatabase(newUser)
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    func emailLogin(_ email: String, password: String, callback: @escaping (FIRUser?)-> ()) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error)
                callback(nil)
            } else {
                callback(user)
            }
        }
    }
    
    func addNewUserToDatabase(_ newUser: NewUser) {
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
    
    func checkUsernameAvaliability(_ username: String, callback: @escaping (Bool) -> ()) {
        self.myRootRef.child("userLookup/usernames/\(username)").observeSingleEvent(of: .value, with: {snapshot in
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

    func callVerification(_ phoneNumber: String, callback: @escaping (Bool) -> ()) {
//        let verification = CalloutVerification(applicationKey: "938e93e3-fab4-4ce4-97e1-3e463891326a", phoneNumber: phoneNumber)
//        verification.initiate({(valid, error) in
//            if let error = error {
//                print("verification error: \(error)")
//                callback(false)
//            } else if !valid {
//                print("invalid verification")
//                callback(false)
//            } else {
//                print("number verified")
//                callback(true)
//            }
//        })
    }
    
    func resetPasswordEmail(_ email: String, callback: @escaping (Bool) -> ()) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print(error)
                callback(false)
            } else {
                callback(true)
            }
        }
    }
    
    
    // MARK: Facebook Graph Methods
    
    func getActiveFBID(_ callback: @escaping (String) -> ()) {
        
        let request = FBSDKGraphRequest(graphPath: "/me", parameters: nil, httpMethod: "GET")
        
        request?.start(completionHandler: { (connection, result, error) in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                let resultdict = result as! NSDictionary
                callback(resultdict.object(forKey: "id") as! String)
            }
        })
    }
}
