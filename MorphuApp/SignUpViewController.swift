//
//  SignUpViewController.swift
//  
//
//  Created by Dylan Wight on 6/11/16.
//
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    let validImage = UIImage(named: "Liked")
    let invalidImage = UIImage(named: "Like")
    
    let newUser = API.sharedInstance.newUser

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBOutlet weak var emailValidIndicator: UIImageView!
    @IBOutlet weak var passwordValidIndicator: UIImageView!
    
    var emailValid = false
    var passwordValid = false
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailValidIndicator.image = invalidImage
        passwordValidIndicator.image = invalidImage
        nextButton.enabled = false
        
        emailInput.delegate = self
        passwordInput.delegate = self
        
        emailInput.addTarget(self, action: #selector(SignUpViewController.emailDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)

        
        passwordInput.addTarget(self, action: #selector(SignUpViewController.passwordDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        emailInput.becomeFirstResponder()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            if emailValid {
                passwordInput.becomeFirstResponder()
            }
        } else if nextButton.enabled {
            textField.resignFirstResponder()
            UIApplication.sharedApplication().sendAction(nextButton.action, to: nextButton.target, from: nil, forEvent: nil)
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    @objc private func emailDidChange(sender: UITextField) {
        if isValidEmail(sender.text!) {
            emailValidIndicator.image = validImage
            emailValid = true
            if passwordValid {
                nextButton.enabled = true
            }
        } else {
            emailValidIndicator.image = invalidImage
            emailValid = true
            nextButton.enabled = false
        }
    }
    
    @objc private func passwordDidChange(sender: UITextField) {
        if isValidPassword(sender.text) {
            passwordValidIndicator.image = validImage
            passwordValid = true
            if emailValid {
                nextButton.enabled = true
            }
        } else {
            passwordValidIndicator.image = invalidImage
            passwordValid = true
            nextButton.enabled = false
        }
    }
    
    private func isValidEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    private func isValidPassword(password: String?) -> Bool {
        if password?.characters.count > 5 {
            return true
        } else {
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.newUser.email = emailInput.text
        self.newUser.password = passwordInput.text
    }
}
