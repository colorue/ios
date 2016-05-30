//
//  LoginViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/18/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let api = API.sharedInstance
    let prefs = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var feedback: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.text = prefs.stringForKey("username")
        password.text = prefs.stringForKey("password")
        
        
        
        let chevronBack = UIImage(named: "ChevronBack")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.tintColor = UIColor.whiteColor()
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        backButton.setImage(chevronBack, forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(LoginViewController.unwindToOnboarding(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        username.becomeFirstResponder()
    }
    
    @IBAction func login(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().synchronize()
        self.feedback.text = ""
        activityIndicator.startAnimating()
        //api.login(username.text!, password: password.text!, callback: loginCallback)
    }
    
    func loginCallback(loginValid: Bool) {
        activityIndicator.stopAnimating()
        if (loginValid) {
            prefs.setValue(true, forKey: "loggedIn")
            prefs.setValue(username.text!, forKey: "username")
            prefs.setValue(password.text!, forKey: "password")
            //api.loadData()
            feedback.text = "Logged In!"
            self.performSegueWithIdentifier("toTabController", sender: self)
        } else {
            feedback.text = "Invalid Log in"
        }
    }
    
    func unwindToOnboarding(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindToOnboarding", sender: self)
    }
}