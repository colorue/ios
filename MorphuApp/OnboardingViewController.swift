//
//  OnboardingViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 5/5/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fb = FBSDKLoginButton()
        
        fb.center = view.center
//        view.addSubview(fb)
        
        facebookButton.layer.cornerRadius = 3
        
        signUpButton.layer.cornerRadius = 4
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = blackColor.CGColor
        
        logginButton.layer.cornerRadius = 5
        logginButton.layer.borderWidth = 1
        logginButton.layer.borderColor = blackColor.CGColor
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
            activityIndicator.stopAnimating()
            self.performSegueWithIdentifier("facebookRegister", sender: self)
        case .LoggedIn:
            API.sharedInstance.checkLoggedIn(loginCallback)
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