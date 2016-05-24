//
//  onboardingViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 5/5/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
//import FBSDKLoginKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var animation: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func facebookButton(sender: AnyObject) {
        API.sharedInstance.connectWithFacebook(self, callback: facebookCallback)
    }
    
    func facebookCallback(valid: Bool) {
        if valid {
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue(true, forKey: "loggedIn")
            performSegueWithIdentifier("facebookLogin", sender: self)
        }
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    @IBAction func backToOnBoarding(segue: UIStoryboardSegue) {}
}