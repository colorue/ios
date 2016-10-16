//
//  SignUpViewController.swift
//  
//
//  Created by Dylan Wight on 6/11/16.
//
//

import UIKit
import Firebase
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
        
        let color = Theme.red
        self.navigationController!.navigationBar.tintColor = color
        nextButton.tintColor = color
        emailInput.tintColor = color
        passwordInput.tintColor = color
        
        emailValidIndicator.image = invalidImage
        passwordValidIndicator.image = invalidImage
        nextButton.isEnabled = false
        
        emailInput.delegate = self
        passwordInput.delegate = self
        
        emailInput.addTarget(self, action: #selector(SignUpViewController.emailDidChange(_:)), for: UIControlEvents.editingChanged)
        passwordInput.addTarget(self, action: #selector(SignUpViewController.passwordDidChange(_:)), for: UIControlEvents.editingChanged)
        
        emailInput.text = newUser.email
        passwordInput.text = newUser.password
        
        self.emailDidChange(emailInput)
        self.passwordDidChange(passwordInput)
        
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
        self.navigationController!.navigationBar.tintColor = Theme.red
        emailInput.becomeFirstResponder()
        FIRAnalytics.logEvent(withName: "SignUpViewController", parameters: [:])
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            if emailValid {
                passwordInput.becomeFirstResponder()
            }
        } else if nextButton.isEnabled {
            textField.resignFirstResponder()
            UIApplication.shared.sendAction(nextButton.action!, to: nextButton.target, from: nil, for: nil)
        }
        return true
    }
    
    @objc fileprivate func emailDidChange(_ sender: UITextField) {
        self.newUser.email = sender.text
        if isValidEmail(sender.text!) {
            emailValidIndicator.image = validImage
            emailValid = true
            if passwordValid {
                nextButton.isEnabled = true
            }
        } else {
            emailValidIndicator.image = invalidImage
            emailValid = true
            nextButton.isEnabled = false
        }
    }
    
    @objc fileprivate func passwordDidChange(_ sender: UITextField) {
        self.newUser.password = sender.text
        if isValidPassword(sender.text) {
            passwordValidIndicator.image = validImage
            passwordValid = true
            if emailValid {
                nextButton.isEnabled = true
            }
        } else {
            passwordValidIndicator.image = invalidImage
            passwordValid = true
            nextButton.isEnabled = false
        }
    }
    
    fileprivate func isValidEmail(_ candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    fileprivate func isValidPassword(_ password: String?) -> Bool {
        if password?.characters.count > 5 {
            return true
        } else {
            return false
        }
    }
}
