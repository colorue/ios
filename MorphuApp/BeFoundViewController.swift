//
//  BeFoundViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 6/11/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//


import UIKit

class BeFoundViewController: UIViewController, UITextFieldDelegate {
    
    let validImage = UIImage(named: "Liked")
    let invalidImage = UIImage(named: "Like")
    
    let newUser = API.sharedInstance.newUser
    
    @IBOutlet weak var nameInput: UITextField!
    
    @IBOutlet weak var phoneNumberInput: UITextField!
    @IBOutlet weak var confirmPhoneButton: UIButton!
    
    @IBOutlet weak var confirmationCodeInput: UITextField!
    @IBOutlet weak var confirmationCodeValid: UIImageView!
    
    @IBOutlet weak var confirmationStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmationCodeValid.image = invalidImage
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        nameInput.becomeFirstResponder()
    }
    
    @objc private func confirmationCodeDidChange(sender: UITextField) {
        if isValidUsername(sender.text!) {
            confirmationCodeValid.image = validImage
        } else {
            confirmationCodeValid.image = invalidImage
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        if nextButton.enabled {
//            usernameInput.resignFirstResponder()
//            UIApplication.sharedApplication().sendAction(nextButton.action, to: nextButton.target, from: nil, forEvent: nil)
//        } else {
//            usernameInput.resignFirstResponder()
//        }
        
        return true
    }
    
    private func isValidUsername(candidate: String) -> Bool {
        let usernameRegex = "[A-Z0-9a-z_]{2,15}"
        return NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluateWithObject(candidate)
    }
    
    
    
    @IBAction func createAccount(sender: UIBarButtonItem) {
        self.newUser.fullName = nameInput.text
        self.newUser.phoneNumber = phoneNumberInput.text
        print(newUser.toAnyObject())
    }
    
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        self.newUser.fullName = nameInput.text
//        self.newUser.phoneNumber = phoneNumberInput.text
//        
//        print(newUser.toAnyObject())
//    }
}
