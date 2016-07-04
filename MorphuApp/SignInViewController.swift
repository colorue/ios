//
//  SignInViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 6/11/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//


import UIKit
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate, APIDelagate {
    
    
    @IBOutlet weak var drawing: UIImageView!
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    var emailFirstResponder = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = orangeColor
        self.navigationController!.navigationBar.tintColor = color
        doneButton.tintColor = color
        emailInput.tintColor = color
        passwordInput.tintColor = color
        
        emailInput.delegate = self
        passwordInput.delegate = self
        
        emailInput.addTarget(self, action: #selector(SignInViewController.emailDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        doneButton.enabled = false
        forgotPasswordButton.enabled = false
        
        if let email = prefs.stringForKey("email") {
            emailInput.text = email
            doneButton.enabled = true
            forgotPasswordButton.enabled = true
        }
        
        if let password = prefs.stringForKey("password") {
            passwordInput.text = password
        }
        
        
        let drawingLook = UILongPressGestureRecognizer(target: self, action: #selector(SignUpViewController.drawingTap(_:)))
        drawingLook.minimumPressDuration = 0.2
        drawing.addGestureRecognizer(drawingLook)
    }
    
    func drawingTap(sender: UILongPressGestureRecognizer) {
        if sender.state ==  .Began {
            if emailInput.isFirstResponder() {
                emailFirstResponder = true
                emailInput.resignFirstResponder()
            } else {
                emailFirstResponder = false
                passwordInput.resignFirstResponder()
            }
        } else if sender.state ==  .Ended {
            if emailFirstResponder {
                emailInput.becomeFirstResponder()
            } else {
                passwordInput.becomeFirstResponder()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        emailInput.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            passwordInput.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            UIApplication.sharedApplication().sendAction(doneButton.action, to: doneButton.target, from: nil, forEvent: nil)
        }
        return true
    }
    
    @objc private func emailDidChange(sender: UITextField) {
        if isValidEmail(sender.text!) {
            doneButton.enabled = true
            forgotPasswordButton.enabled = true
        } else {
            doneButton.enabled = false
            forgotPasswordButton.enabled = false
        }
    }
    
    private func isValidEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    @IBAction func doneAction(sender: UIBarButtonItem) {
        activityIndicator.startAnimating()
        AuthAPI.sharedInstance.emailLogin(emailInput.text!, password: passwordInput.text!, callback: logginCallback)
    }
    
    func logginCallback(user: FIRUser?) {
        AuthAPI.sharedInstance.checkLoggedIn({ loggedIn in
            if loggedIn {
                API.sharedInstance.delagate = self
                API.sharedInstance.loadData()
                self.prefs.setValue(self.emailInput.text, forKey: "email")
                self.prefs.setValue(self.passwordInput.text, forKey: "password")
            } else {
                self.activityIndicator.stopAnimating()
            }
        })
    }
    
    @IBAction func forgotPassword(sender: UIButton) {
        let forgotPasswordEmail = UIAlertController(title: "Forgot Password", message: "Send password reset email to '\(emailInput.text!)'?" , preferredStyle: UIAlertControllerStyle.Alert)
        forgotPasswordEmail.addAction(UIAlertAction(title: "Send", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            AuthAPI.sharedInstance.resetPasswordEmail(self.emailInput.text!, callback: self.passwordResetCallback)
            }))
        forgotPasswordEmail.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(forgotPasswordEmail, animated: true, completion: nil)
    }
    
    private func passwordResetCallback(valid: Bool) {
        if valid {
            let emailSent = UIAlertController(title: "Email Sent!", message: nil , preferredStyle: UIAlertControllerStyle.Alert)
            emailSent.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.presentViewController(emailSent, animated: true, completion: nil)
            }
        } else {
            let emailSent = UIAlertController(title: "Issue resetting password", message: "We couldn't find an account associated with '\(emailInput.text!)'. Please try again." , preferredStyle: UIAlertControllerStyle.Alert)
            emailSent.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.presentViewController(emailSent, animated: true, completion: nil)
            }
        }
    }
    
    func refresh() {
        print("sign in")
        activityIndicator.stopAnimating()
        self.performSegueWithIdentifier("signIn", sender: self)
    }
    
}
