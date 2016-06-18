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
//        API.sharedInstance.logout()
        self.loginCallback(AuthAPI.sharedInstance.checkLoggedIn())
    }
    
    private func loginCallback(user: FIRUser?) {
        if let user = user {
            API.sharedInstance.loadData(user)
            self.performSegueWithIdentifier("toMainController", sender: self)
        } else {
            API.sharedInstance.clearData()
            AuthAPI.sharedInstance.logout()
            self.performSegueWithIdentifier("toLoginController", sender: self)
        }
    }
}
