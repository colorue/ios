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
        signUpButton.layer.borderColor = Theme.black.cgColor
        
        logginButton.layer.cornerRadius = 4
        logginButton.layer.borderWidth = 1
        logginButton.layer.borderColor = Theme.black.cgColor
        
        API.sharedInstance.loadPopularUsers()
    }

    
    @IBAction func facebookButton(_ sender: AnyObject) {
        activityIndicator.startAnimating()
        AuthAPI.sharedInstance.connectWithFacebook(self, callback: facebookCallback)
    }
    
    func facebookCallback(_ result: FacebookLoginResult, user: FIRUser?) {
        switch (result) {
        case .failed:
            activityIndicator.stopAnimating()
        case .registered:
            activityIndicator.stopAnimating()
            API.sharedInstance.loadFacebookFriends()
            FIRAnalytics.logEvent(withName: "registeredWithFacebook", parameters: [:])

            self.performSegue(withIdentifier: "facebookRegister", sender: self)
        case .loggedIn:
            FIRAnalytics.logEvent(withName: "loggedInWithFacebook", parameters: [:])
            API.sharedInstance.delagate = self
            API.sharedInstance.loadData()
        }
    }
    
    func refresh() {
        activityIndicator.stopAnimating()
        self.performSegue(withIdentifier: "toMainController", sender: self)
    }
}
