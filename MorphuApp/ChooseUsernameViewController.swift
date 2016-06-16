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
    
    let api = API.sharedInstance
    
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var usernameValidIndicator: UIImageView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var drawing: UIImageView!
    @IBOutlet weak var checkAvailabilityButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
        
        usernameValidIndicator.image = invalidImage
        nextButton.enabled = false
        
        usernameInput.delegate = self
        usernameInput.addTarget(self, action: #selector(ChooseUsernameViewController.usernameDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        usernameInput.text = newUser.username
        checkAvailabilityButton.enabled = false
    
        let drawingLook = UILongPressGestureRecognizer(target: self, action: #selector(SignUpViewController.drawingTap(_:)))
        drawingLook.minimumPressDuration = 0.2
        drawing.addGestureRecognizer(drawingLook)
    }
    
    func drawingTap(sender: UILongPressGestureRecognizer) {
        if sender.state ==  .Began {
            usernameInput.resignFirstResponder()
        } else if sender.state ==  .Ended {
            usernameInput.becomeFirstResponder()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = false

        usernameInput.becomeFirstResponder()
    }
    
    @objc private func usernameDidChange(sender: UITextField) {
        nextButton.enabled = false
        checkAvailabilityButton.hidden = false
        usernameValidIndicator.hidden = true
        
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
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.newUser.username = usernameInput.text
        
//        if let onboarding = segue.destinationViewController as? OnboardingViewController {
//            print("hide bar")
//            onboarding.navigationController?.navigationBarHidden = true
//        }
    }
}
