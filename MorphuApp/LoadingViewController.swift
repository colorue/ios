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
import AirshipKit

class LoadingViewController: UIViewController, APIDelagate {
    let prefs = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidAppear(animated: Bool) {
//        AuthAPI.sharedInstance.logout()
        AuthAPI.sharedInstance.checkLoggedIn(loginCallback)
    }
    
    private func loginCallback(loggedIn: Bool) {
        let api = API.sharedInstance
        if loggedIn {
            api.delagate = self
            api.loadData()
        } else {
            api.clearData()
            AuthAPI.sharedInstance.logout()
            self.performSegueWithIdentifier("toLoginController", sender: self)
        }
    }
    
    func refresh() {
        let config = UAConfig.defaultConfig()
        config.analyticsEnabled = false
        config.developmentLogLevel = UALogLevel.Warn
        UAirship.takeOff(config)
        self.performSegueWithIdentifier("toMainController", sender: self)
    }
}