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
        
        var animationImages = [UIImage]()
        for i in  0...50 {
            animationImages.append(UIImage(named: String(i))!)
        }
        animation.image = UIImage.animatedImageWithImages(animationImages, duration: 30.0)!
        animation.startAnimating()
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
    
    @IBAction func backToOnBoarding(segue: UIStoryboardSegue) {}
}