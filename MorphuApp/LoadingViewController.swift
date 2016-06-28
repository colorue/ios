//
//  LoadingViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/29/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoadingViewController: UIViewController {
    let prefs = NSUserDefaults.standardUserDefaults()
    
    override func viewDidAppear(animated: Bool) {
//        AuthAPI.sharedInstance.logout()
        AuthAPI.sharedInstance.checkLoggedIn(loginCallback)
    }
    
    private func loginCallback(loggedIn: Bool) {
        
        print("loginCallback")
        if loggedIn {
            API.sharedInstance.loadData()
            self.performSegueWithIdentifier("toMainController", sender: self)
        } else {
            API.sharedInstance.clearData()
            AuthAPI.sharedInstance.logout()
            self.performSegueWithIdentifier("toLoginController", sender: self)
        }
    }
}