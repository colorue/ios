//
//  ChooseUsernameViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 6/11/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//


import UIKit
import Firebase

class ChooseUsernameViewController: UIViewController, UITextFieldDelegate {
    
    let validImage = UIImage(named: "Check")
    let invalidImage = UIImage(named: "X")
    
    let newUser = AuthAPI.sharedInstance.newUser
    
    let api = AuthAPI.sharedInstance
    
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var usernameValidIndicator: UIImageView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var drawing: UIImageView!
    @IBOutlet weak var checkAvailabilityButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = blueColor
        self.navigationController!.navigationBar.tintColor = color
        nextButton.tintColor = color
        usernameInput.tintColor = color
        checkAvailabilityButton.tintColor = color
        
        self.navigationController?.navigationBarHidden = false
        
        usernameValidIndicator.image = invalidImage
        nextButton.enabled = false
        
        usernameInput.delegate = self
        usernameInput.addTarget(self, action: #selector(ChooseUsernameViewController.usernameDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        usernameInput.text = newUser.username
        self.usernameDidChange(usernameInput)
        self.checkAvailability(checkAvailabilityButton)
        
        checkAvailabilityButton.enabled = false
    
        let drawingLook = UILongPressGestureRecognizer(target: self, action: #selector(SignUpViewController.drawingTap(_:)))
        drawingLook.minimumPressDuration = 0.2
        drawing.addGestureRecognizer(drawingLook)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.navigationController!.navigationBar.tintColor = blueColor
        
        usernameInput.becomeFirstResponder()
        FIRAnalytics.logEventWithName("ChooseUsernameViewController", parameters: [:])
    }
    
    func drawingTap(sender: UILongPressGestureRecognizer) {
        if sender.state ==  .Began {
            usernameInput.resignFirstResponder()
        } else if sender.state ==  .Ended {
            usernameInput.becomeFirstResponder()
        }
    }
    
    @objc private func usernameDidChange(sender: UITextField) {
        nextButton.enabled = false
        checkAvailabilityButton.hidden = false
        usernameValidIndicator.hidden = true
        
//        self.newUser.username = sender.text

        api.releaseUsernameHold()

        if isValidUsername(sender.text!) {
            checkAvailabilityButton.enabled = true
        } else {
            checkAvailabilityButton.enabled = false
        }
    }
    
    @IBAction func checkAvailability(sender: UIButton) {
        checkAvailabilityButton.hidden = true
        api.checkUsernameAvaliability(usernameInput.text!, callback: usernameAvaliableCallback)
    }
    
    @objc private func usernameAvaliableCallback(avaliable: Bool) {
        // stopSpining
        usernameValidIndicator.hidden = false
        if avaliable {
            usernameValidIndicator.image = validImage
            nextButton.enabled = true
        } else {
            usernameValidIndicator.image = invalidImage
        }
    }
    
    private func isValidUsername(candidate: String) -> Bool {
        let usernameRegex = "[A-Z0-9a-z_]{2,15}"
        return NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluateWithObject(candidate)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if nextButton.enabled {
            usernameInput.resignFirstResponder()
            UIApplication.sharedApplication().sendAction(nextButton.action, to: nextButton.target, from: nil, forEvent: nil)
        } else {
            self.checkAvailability(checkAvailabilityButton)
        }
        
        return true
    }
}
