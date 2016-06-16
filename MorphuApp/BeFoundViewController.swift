//
//  BeFoundViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 6/11/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//


import UIKit

class BeFoundViewController: UIViewController, UITextFieldDelegate {
    
    let api = API.sharedInstance
    let prefs = NSUserDefaults.standardUserDefaults()

    let validImage = UIImage(named: "Liked")
    let invalidImage = UIImage(named: "Like")
    
    let newUser = API.sharedInstance.newUser
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var joinButton: UIBarButtonItem!
    @IBOutlet weak var drawing: UIImageView!
    
    @IBOutlet weak var verificatoinButton: UIButton!
    
    @IBOutlet weak var verifiedIndicator: UIImageView!
    
    @IBOutlet weak var callingIndicatoy: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameInput.text = newUser.fullName
        phoneNumberInput.text = newUser.phoneNumber
        
        nameInput.delegate = self
        phoneNumberInput.delegate = self
        verificatoinButton.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        nameInput.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if phoneNumberInput.isFirstResponder() && joinButton.enabled{
            phoneNumberInput.resignFirstResponder()
            nameInput.resignFirstResponder()
        UIApplication.sharedApplication().sendAction(joinButton.action, to: joinButton.target, from: nil, forEvent: nil)
        } else if nameInput.isFirstResponder() {
            phoneNumberInput.becomeFirstResponder()
        }
        
        return true
    }
    
    @IBAction func answerVerificationCall(sender: UIButton) {
        
        let stringArray = phoneNumberInput.text!.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let phone = "+1" + stringArray.joinWithSeparator("")
        
        self.verificatoinButton.hidden = true
        self.callingIndicatoy.startAnimating()
        self.phoneNumberInput.enabled = false

        api.callVerification(phone, callback: { valid in
            self.callingIndicatoy.stopAnimating()
            if valid {
                self.verifiedIndicator.hidden = false
                self.newUser.phoneNumber = phone
            } else {
                self.verificatoinButton.hidden = false
                self.phoneNumberInput.enabled = true
            }
        })
    }
    
    
    @IBAction func createAccount(sender: UIBarButtonItem) {
        
        joinButton.enabled = false
        activityIndicator.startAnimating()

        self.newUser.fullName = nameInput.text
        
        if newUser.FacebookSignUp {
            api.addNewUserToDatabase(newUser)
            self.performSegueWithIdentifier("login", sender: self)
        } else {
            api.createEmailAccount(newUser, callback: createAccountCallback)
        }
    }
    
    func createAccountCallback(valid: Bool) {
        api.emailLogin(newUser.email!, password: newUser.password!, callback: loginCallback)
    }
    
    func loginCallback(valid: Bool) {
        activityIndicator.stopAnimating()
        if valid {
            if !newUser.FacebookSignUp {
                prefs.setValue(newUser.email, forKey: "email")
                prefs.setValue(newUser.password, forKey: "password")
            }
            self.performSegueWithIdentifier("login", sender: self)
        } else {
            print("login failed")
            joinButton.enabled = true
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField == phoneNumberInput
        {
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            
            self.verificatoinButton.enabled = newString.characters.count > 13

            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            let decimalString = components.joinWithSeparator("") as NSString
            
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            
            return false
        }
        else
        {
            return true
        }
    }
}
