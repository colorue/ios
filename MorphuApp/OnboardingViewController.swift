//
//  OnboardingViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 5/5/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
//import FBSDKLoginKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func facebookButton(sender: AnyObject) {
        activityIndicator.startAnimating()
        API.sharedInstance.connectWithFacebook(self, callback: facebookCallback)
    }
    
    func facebookCallback(result: FacebookLoginResult) {

        switch (result) {
        case .Failed:
            activityIndicator.stopAnimating()
        case .Registered:
            break
        case .LoggedIn:
            break
//            API.sharedInstance.checkLoggedIn(loginCallback)
        }
    }
    
    func loginCallback(loginValid: Bool) {
        activityIndicator.stopAnimating()
        if loginValid {
            self.performSegueWithIdentifier("toMainController", sender: self)
        }
    }
    
    @IBAction func backToOnBoarding(segue: UIStoryboardSegue) {}
}