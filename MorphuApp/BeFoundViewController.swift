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
    let prefs = UserDefaults.standard

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
            self.verificatoinButton.isHidden = true
            self.verifiedIndicator.isHidden = false
            self.phoneNumberInput.isEnabled = false
        }
        
        nameInput.delegate = self
        nameInput.addTarget(self, action: #selector(BeFoundViewController.nameDidChange(_:)), for: UIControlEvents.editingChanged)
        
        phoneNumberInput.delegate = self
        verificatoinButton.isEnabled = false
        
        let drawingLook = UILongPressGestureRecognizer(target: self, action: #selector(SignUpViewController.drawingTap(_:)))
        drawingLook.minimumPressDuration = 0.2
        drawing.addGestureRecognizer(drawingLook)
        
        FIRAnalytics.logEvent(withName: "BeFoundViewController", parameters: [:])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController!.navigationBar.tintColor = purpleColor
        nameInput.becomeFirstResponder()
    }
    
    @objc fileprivate func nameDidChange(_ sender: UITextField) {
        self.newUser.fullName = sender.text
    }
    
    func drawingTap(_ sender: UILongPressGestureRecognizer) {
        if sender.state ==  .began {
            if nameInput.isFirstResponder {
                nameFirstResponder = true
                nameInput.resignFirstResponder()
            } else {
                nameFirstResponder = false
                phoneNumberInput.resignFirstResponder()
            }
        } else if sender.state ==  .ended {
            if nameFirstResponder {
                nameInput.becomeFirstResponder()
            } else {
                phoneNumberInput.becomeFirstResponder()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nameInput.isFirstResponder {
            if phoneNumberInput.isEnabled {
                phoneNumberInput.becomeFirstResponder()
            } else {
                nameInput.resignFirstResponder()
            }
        } else if verificatoinButton.isEnabled {
            self.answerVerificationCall(verificatoinButton)
        }
        
        return true
    }
    
    @IBAction func answerVerificationCall(_ sender: UIButton) {
        
        let stringArray = phoneNumberInput.text!.components(
            separatedBy: CharacterSet.decimalDigits.inverted)
        let phone = "+1" + stringArray.joined(separator: "")
        
        self.verificatoinButton.isHidden = true
        self.callingIndicatoy.startAnimating()
        self.phoneNumberInput.isEnabled = false

        api.callVerification(phone, callback: { valid in
            self.callingIndicatoy.stopAnimating()
            if valid {
                self.verifiedIndicator.isHidden = false
                self.newUser.phoneNumber = phone
                FIRAnalytics.logEvent(withName: "phoneVerified", parameters: [:])
            } else {
                self.verificatoinButton.isHidden = false
                self.phoneNumberInput.isEnabled = true
            }
        })
    }
    
    
    @IBAction func createAccount(_ sender: UIBarButtonItem) {
        
        joinButton.isEnabled = false
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
    
    fileprivate func createEmailAccountCallback(_ valid: Bool) {
        api.emailLogin(newUser.email!, password: newUser.password!, callback: loginCallback)
    }
    
    func loginCallback(_ user: FIRUser?) {
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
            joinButton.isEnabled = true
        }
    }
    
    
    func refresh() {
        activityIndicator.stopAnimating()
        FIRAnalytics.logEvent(withName: "accountCreated", parameters: [:])
        self.performSegue(withIdentifier: "toFollowPeople", sender: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == phoneNumberInput
        {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            
            self.verificatoinButton.isEnabled = newString.characters.count > 13

            let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            
            return false
        }
        else
        {
            return true
        }
    }

}
