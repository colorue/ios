//
//  RegisterViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 5/5/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
//import FBSDKLoginKit

class RegisterViewController: UIViewController {
    
    let api = API.sharedInstance
    let prefs = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var feedback: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let chevronBack = UIImage(named: "ChevronBack")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.tintColor = UIColor.whiteColor()
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        backButton.setImage(chevronBack, forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(LoginViewController.unwindToOnboarding(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        nameInput.becomeFirstResponder()
    }
    
    @IBAction func register(sender: UIButton) {
        api.connectWithFacebook(self, callback: registerCallback)
//        self.feedback.text = ""
//        activityIndicator.startAnimating()
//        api.register(nameInput.text!, email: emailInput.text!, password: passwordInput.text!, callback: registerCallback)
    }
    
    func registerCallback(registerValid: Bool) {
        activityIndicator.stopAnimating()
        if (registerValid) {
            feedback.text = "Registered!"
            prefs.setValue(emailInput.text!, forKey: "username")
            prefs.setValue(passwordInput.text!, forKey: "password")
            performSegueWithIdentifier("toLoginController", sender: self)
        } else {
            feedback.text = "Registration Failed"
        }
    }
    
    func unwindToOnboarding(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindToOnboarding", sender: self)
    }
}