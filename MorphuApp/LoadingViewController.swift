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
        API.sharedInstance.checkLoggedIn(loginCallback)
    }
    
    func loginCallback(loginValid: Bool) {
        if loginValid {
            self.performSegueWithIdentifier("toMainController", sender: self)
        } else {
            API.sharedInstance.logout()
            self.performSegueWithIdentifier("toLoginController", sender: self)
        }
    }
}
