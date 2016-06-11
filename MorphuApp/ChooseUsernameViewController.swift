//
//  ChooseUsernameViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 6/11/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//


import UIKit

class ChooseUsernameViewController: UIViewController, UITextFieldDelegate {
    
    let validImage = UIImage(named: "Liked")
    let invalidImage = UIImage(named: "Like")
    
    let newUser = API.sharedInstance.newUser
    
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var usernameValidIndicator: UIImageView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameValidIndicator.image = invalidImage
        nextButton.enabled = false
        
        usernameInput.delegate = self
        usernameInput.addTarget(self, action: #selector(ChooseUsernameViewController.usernameDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        usernameInput.becomeFirstResponder()
    }
    
    @objc private func usernameDidChange(sender: UITextField) {
        if isValidUsername(sender.text!) {
            usernameValidIndicator.image = validImage
            nextButton.enabled = true
        } else {
            usernameValidIndicator.image = invalidImage
            nextButton.enabled = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if nextButton.enabled {
            usernameInput.resignFirstResponder()
            UIApplication.sharedApplication().sendAction(nextButton.action, to: nextButton.target, from: nil, forEvent: nil)
        } else {
            usernameInput.resignFirstResponder()
        }
        
        return true
    }
    
    private func isValidUsername(candidate: String) -> Bool {
        let usernameRegex = "[A-Z0-9a-z_]{2,15}"
        return NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluateWithObject(candidate)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.newUser.username = usernameInput.text
    }
}
