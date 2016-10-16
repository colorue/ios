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
    
    let prefs = UserDefaults.standard
    
    var emailFirstResponder = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = Theme.orange
        self.navigationController!.navigationBar.tintColor = color
        doneButton.tintColor = color
        emailInput.tintColor = color
        passwordInput.tintColor = color
        
        emailInput.delegate = self
        passwordInput.delegate = self
        
        emailInput.addTarget(self, action: #selector(SignInViewController.emailDidChange(_:)), for: UIControlEvents.editingChanged)
        doneButton.isEnabled = false
        forgotPasswordButton.isEnabled = false
        
        if let email = prefs.string(forKey: "email") {
            emailInput.text = email
            doneButton.isEnabled = true
            forgotPasswordButton.isEnabled = true
        }
        
        if let password = prefs.string(forKey: "password") {
            passwordInput.text = password
        }
        
        
        let drawingLook = UILongPressGestureRecognizer(target: self, action: #selector(SignUpViewController.drawingTap(_:)))
        drawingLook.minimumPressDuration = 0.2
        drawing.addGestureRecognizer(drawingLook)
    }
    
    func drawingTap(_ sender: UILongPressGestureRecognizer) {
        if sender.state ==  .began {
            if emailInput.isFirstResponder {
                emailFirstResponder = true
                emailInput.resignFirstResponder()
            } else {
                emailFirstResponder = false
                passwordInput.resignFirstResponder()
            }
        } else if sender.state ==  .ended {
            if emailFirstResponder {
                emailInput.becomeFirstResponder()
            } else {
                passwordInput.becomeFirstResponder()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        emailInput.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            passwordInput.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            UIApplication.shared.sendAction(doneButton.action!, to: doneButton.target, from: nil, for: nil)
        }
        return true
    }
    
    @objc fileprivate func emailDidChange(_ sender: UITextField) {
        if isValidEmail(sender.text!) {
            doneButton.isEnabled = true
            forgotPasswordButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
            forgotPasswordButton.isEnabled = false
        }
    }
    
    fileprivate func isValidEmail(_ candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        activityIndicator.startAnimating()
        AuthAPI.sharedInstance.emailLogin(emailInput.text!, password: passwordInput.text!, callback: logginCallback)
    }
    
    func logginCallback(_ user: FIRUser?) {
        AuthAPI.sharedInstance.checkLoggedIn({ loggedIn in
            if loggedIn {
                FIRAnalytics.logEvent(withName: "signedInWithEmail", parameters: [:])
                API.sharedInstance.delagate = self
                API.sharedInstance.loadData()
                self.prefs.setValue(self.emailInput.text, forKey: "email")
                self.prefs.setValue(self.passwordInput.text, forKey: "password")
            } else {
                self.activityIndicator.stopAnimating()
            }
        })
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        let forgotPasswordEmail = UIAlertController(title: "Forgot Password", message: "Send password reset email to '\(emailInput.text!)'?" , preferredStyle: UIAlertControllerStyle.alert)
        forgotPasswordEmail.addAction(UIAlertAction(title: "Send", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            AuthAPI.sharedInstance.resetPasswordEmail(self.emailInput.text!, callback: self.passwordResetCallback)
            }))
        forgotPasswordEmail.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(forgotPasswordEmail, animated: true, completion: nil)
    }
    
    fileprivate func passwordResetCallback(_ valid: Bool) {
        if valid {
            FIRAnalytics.logEvent(withName: "resetPasswordEmailSent", parameters: [:])
            let emailSent = UIAlertController(title: "Email Sent!", message: nil , preferredStyle: UIAlertControllerStyle.alert)
            emailSent.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            OperationQueue.main.addOperation {
                self.present(emailSent, animated: true, completion: nil)
            }
        } else {
            let emailSent = UIAlertController(title: "Issue resetting password", message: "We couldn't find an account associated with '\(emailInput.text!)'. Please try again." , preferredStyle: UIAlertControllerStyle.alert)
            emailSent.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            OperationQueue.main.addOperation {
                self.present(emailSent, animated: true, completion: nil)
            }
        }
    }
    
    func refresh() {
        activityIndicator.stopAnimating()
        self.performSegue(withIdentifier: "signIn", sender: self)
    }
    
}
