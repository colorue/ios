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

class LoadingViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        AuthAPI.sharedInstance.checkLoggedIn(loginCallback)
    }
    
    fileprivate func loginCallback(_ loggedIn: Bool) {
        let api = API.sharedInstance
        if loggedIn {
            api.loadData()
            performSegue(withIdentifier: R.segue.loadingViewController.toMainController, sender: self)

        } else {
            api.clearData()
            AuthAPI.sharedInstance.logout()
            performSegue(withIdentifier: R.segue.loadingViewController.toLoginController, sender: self)
        }
    }
}
