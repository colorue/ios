//
//  BeFoundViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 6/11/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//


import UIKit
import Firebase

class BeFoundViewController: UIViewController, UITextFieldDelegate, APIDelagate {
    
    let api = AuthAPI.sharedInstance
    let prefs = NSUserDefaults.standardUserDefaults()

    let validImage = UIImage(named: "Check")
    let invalidImage = UIImage(named: "X")
    
    let newUser = AuthAPI.sharedInstance.newUser
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var joinButton: UIBarButtonItem!
    @IBOutlet weak var drawing: UIImageView!
    
    @IBOutlet weak var verificatoinButton: UIButton!
    @IBOutlet weak var verifiedIndicator: UIImageView!
    @IBOutlet weak var callingIndicatoy: UIActivityIndicatorView!
    
    var nameFirstResponder = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = purpleColor
        self.navigationController!.navigationBar.tintColor = color
        joinButton.tintColor = color
        nameInput.tintColor = color
        phoneNumberInput.tintColor = color
        verificatoinButton.tintColor = color
        
        nameInput.text = newUser.fullName
        
        if let phone = newUser.phoneNumber {
            phoneNumberInput.text = phone
            self.verificatoinButton.hidden = true
            self.verifiedIndicator.hidden = false
            self.phoneNumberInput.enabled = false
        }
        
        nameInput.delegate = self
        nameInput.addTarget(self, action: #selector(BeFoundViewController.nameDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        phoneNumberInput.delegate = self
        verificatoinButton.enabled = false
        
        let drawingLook = UILongPressGestureRecognizer(target: self, action: #selector(SignUpViewController.drawingTap(_:)))
        drawingLook.minimumPressDuration = 0.2
        drawing.addGestureRecognizer(drawingLook)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController!.navigationBar.tintColor = purpleColor
        nameInput.becomeFirstResponder()
    }
    
    @objc private func nameDidChange(sender: UITextField) {
        self.newUser.fullName = sender.text
    }
    
    func drawingTap(sender: UILongPressGestureRecognizer) {
        if sender.state ==  .Began {
            if nameInput.isFirstResponder() {
                nameFirstResponder = true
                nameInput.resignFirstResponder()
            } else {
                nameFirstResponder = false
                phoneNumberInput.resignFirstResponder()
            }
        } else if sender.state ==  .Ended {
            if nameFirstResponder {
                nameInput.becomeFirstResponder()
            } else {
                phoneNumberInput.becomeFirstResponder()
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if nameInput.isFirstResponder() {
            if phoneNumberInput.enabled {
                phoneNumberInput.becomeFirstResponder()
            } else {
                nameInput.resignFirstResponder()
            }
        } else if verificatoinButton.enabled {
            self.answerVerificationCall(verificatoinButton)
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
            API.sharedInstance.delagate = self
            API.sharedInstance.loadData()
        } else {
            api.createEmailAccount(newUser, callback: createEmailAccountCallback)
        }
    }
    
    private func createEmailAccountCallback(valid: Bool) {
        api.emailLogin(newUser.email!, password: newUser.password!, callback: loginCallback)
    }
    
    func loginCallback(user: FIRUser?) {
        activityIndicator.stopAnimating()
        if user != nil {
            if !newUser.FacebookSignUp {
                prefs.setValue(newUser.email, forKey: "email")
                prefs.setValue(newUser.password, forKey: "password")
            }
            API.sharedInstance.delagate = self
            API.sharedInstance.loadData()
        } else {
            print("login failed")
            joinButton.enabled = true
        }
    }
    
    
    func refresh() {
        activityIndicator.stopAnimating()
        self.performSegueWithIdentifier("toFollowPeople", sender: self)
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
