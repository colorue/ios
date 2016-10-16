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
        
        let color = Theme.blue
        self.navigationController!.navigationBar.tintColor = color
        nextButton.tintColor = color
        usernameInput.tintColor = color
        checkAvailabilityButton.tintColor = color
        
        self.navigationController?.isNavigationBarHidden = false
        
        usernameValidIndicator.image = invalidImage
        nextButton.isEnabled = false
        
        usernameInput.delegate = self
        usernameInput.addTarget(self, action: #selector(ChooseUsernameViewController.usernameDidChange(_:)), for: UIControlEvents.editingChanged)
        
        usernameInput.text = newUser.username
        self.usernameDidChange(usernameInput)
        self.checkAvailability(checkAvailabilityButton)
        
        checkAvailabilityButton.isEnabled = false
    
        let drawingLook = UILongPressGestureRecognizer(target: self, action: #selector(SignUpViewController.drawingTap(_:)))
        drawingLook.minimumPressDuration = 0.2
        drawing.addGestureRecognizer(drawingLook)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController!.navigationBar.tintColor = Theme.blue
        
        usernameInput.becomeFirstResponder()
        FIRAnalytics.logEvent(withName: "ChooseUsernameViewController", parameters: [:])
    }
    
    func drawingTap(_ sender: UILongPressGestureRecognizer) {
        if sender.state ==  .began {
            usernameInput.resignFirstResponder()
        } else if sender.state ==  .ended {
            usernameInput.becomeFirstResponder()
        }
    }
    
    @objc fileprivate func usernameDidChange(_ sender: UITextField) {
        nextButton.isEnabled = false
        checkAvailabilityButton.isHidden = false
        usernameValidIndicator.isHidden = true
        
//        self.newUser.username = sender.text

        api.releaseUsernameHold()

        if isValidUsername(sender.text!) {
            checkAvailabilityButton.isEnabled = true
        } else {
            checkAvailabilityButton.isEnabled = false
        }
    }
    
    @IBAction func checkAvailability(_ sender: UIButton) {
        checkAvailabilityButton.isHidden = true
        api.checkUsernameAvaliability(usernameInput.text!, callback: usernameAvaliableCallback)
    }
    
    @objc fileprivate func usernameAvaliableCallback(_ avaliable: Bool) {
        // stopSpining
        usernameValidIndicator.isHidden = false
        if avaliable {
            usernameValidIndicator.image = validImage
            nextButton.isEnabled = true
        } else {
            usernameValidIndicator.image = invalidImage
        }
    }
    
    fileprivate func isValidUsername(_ candidate: String) -> Bool {
        let usernameRegex = "[A-Z0-9a-z_]{2,15}"
        return NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: candidate)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nextButton.isEnabled {
            usernameInput.resignFirstResponder()
            UIApplication.shared.sendAction(nextButton.action!, to: nextButton.target, from: nil, for: nil)
        } else {
            self.checkAvailability(checkAvailabilityButton)
        }
        
        return true
    }
}
