//
//  SignInViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 6/11/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//


import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailInput.delegate = self
        passwordInput.delegate = self
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
    
    @IBAction func doneAction(sender: UIBarButtonItem) {
        API.sharedInstance.emailLogin(emailInput.text!, password: passwordInput.text!, callback: logginCallback)
    }
    
    func logginCallback(valid: Bool) {
        if valid {
            self.performSegueWithIdentifier("signIn", sender: self)
        }
    }
}
