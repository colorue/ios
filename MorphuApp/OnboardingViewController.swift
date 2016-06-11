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
        
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = true
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationController?.navigationBarHidden = false
    }
    
    @IBAction func backToOnBoarding(segue: UIStoryboardSegue) {}
}