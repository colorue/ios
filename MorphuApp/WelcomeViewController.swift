//
//  OnboardingViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 5/5/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController, APIDelagate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookButton.layer.cornerRadius = 4
        
        signUpButton.layer.cornerRadius = 4
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = blackColor.CGColor
        
        logginButton.layer.cornerRadius = 4
        logginButton.layer.borderWidth = 1
        logginButton.layer.borderColor = blackColor.CGColor
        
        API.sharedInstance.loadPopularUsers()
    }

    
    @IBAction func facebookButton(sender: AnyObject) {
        activityIndicator.startAnimating()
        AuthAPI.sharedInstance.connectWithFacebook(self, callback: facebookCallback)
    }
    
    func facebookCallback(result: FacebookLoginResult, user: FIRUser?) {
        switch (result) {
        case .Failed:
            activityIndicator.stopAnimating()
        case .Registered:
            activityIndicator.stopAnimating()
            API.sharedInstance.loadFacebookFriends()
            FIRAnalytics.logEventWithName("registeredWithFacebook", parameters: [:])

            self.performSegueWithIdentifier("facebookRegister", sender: self)
        case .LoggedIn:
            FIRAnalytics.logEventWithName("loggedInWithFacebook", parameters: [:])
            API.sharedInstance.delagate = self
            API.sharedInstance.loadData()
        }
    }
    
    func refresh() {
        activityIndicator.stopAnimating()
        self.performSegueWithIdentifier("toMainController", sender: self)
    }
}