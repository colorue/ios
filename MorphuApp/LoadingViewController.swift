//
//  LoadingViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/29/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoadingViewController: UIViewController, APIDelagate {
    let prefs = UserDefaults.standard
    
    
    override func viewDidAppear(_ animated: Bool) {
//        AuthAPI.sharedInstance.logout()
        AuthAPI.sharedInstance.checkLoggedIn(loginCallback)
    }
    
    fileprivate func loginCallback(_ loggedIn: Bool) {
        let api = API.sharedInstance
        if loggedIn {
            api.delagate = self
            api.loadData()
        } else {
            api.clearData()
            AuthAPI.sharedInstance.logout()
            self.performSegue(withIdentifier: "toLoginController", sender: self)
        }
    }
    
    func refresh() {
        self.performSegue(withIdentifier: "toMainController", sender: self)
    }
}
