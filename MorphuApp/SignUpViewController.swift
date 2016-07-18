//
//  SignUpViewController.swift
//  
//
//  Created by Dylan Wight on 6/11/16.
//
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    let validImage = UIImage(named: "Check")
    let invalidImage = UIImage(named: "X")
    
    let newUser = AuthAPI.sharedInstance.newUser
    
    var emailValid = false
    var passwordValid = false

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBOutlet weak var emailValidIndicator: UIImageView!
    @IBOutlet weak var passwordValidIndicator: UIImageView!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    @IBOutlet weak var drawing: UIImageView!
    
    var emailFirstResponder = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = redColor
        self.navigationController!.navigationBar.tintColor = color
        nextButton.tintColor = color
        emailInput.tintColor = color
        passwordInput.tintColor = color
        
        emailValidIndicator.image = invalidImage
        passwordValidIndicator.image = invalidImage
        nextButton.enabled = false
        
        emailInput.delegate = self
        passwordInput.delegate = self
        
        emailInput.addTarget(self, action: #selector(SignUpViewController.emailDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        passwordInput.addTarget(self, action: #selector(SignUpViewController.passwordDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        emailInput.text = newUser.email
        passwordInput.text = newUser.password
        
        self.emailDidChange(emailInput)
        self.passwordDidChange(passwordInput)
        
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
        self.navigationController!.navigationBar.tintColor = redColor
        emailInput.becomeFirstResponder()
        FIRAnalytics.logEventWithName("SignUpViewController", parameters: [:])
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            if emailValid {
                passwordInput.becomeFirstResponder()
            }
        } else if nextButton.enabled {
            textField.resignFirstResponder()
            UIApplication.sharedApplication().sendAction(nextButton.action, to: nextButton.target, from: nil, forEvent: nil)
        }
        return true
    }
    
    @objc private func emailDidChange(sender: UITextField) {
        self.newUser.email = sender.text
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
        self.newUser.password = sender.text
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
}
