//
//  FriendsViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import MessageUI
import Firebase

class FriendsViewController: UserListViewController {
    
    // MARK: - View Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Invite ", style: .plain, target: self,
                            action: #selector(FriendsViewController.invite(_:)))
    }
    
    @objc fileprivate func invite(_ sender: UIBarButtonItem) {
        sendInvite()
    }
    
    fileprivate func sendInvite() {
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            
            controller.body = "\(api.getActiveUser().username) invited you to the Colorue beta test\nhttps://colorue.herokuapp.com/?token=DrawingT1me"
            controller.messageComposeDelegate = self
            resignFirstResponder()
            present(controller, animated: true, completion: nil)
        } else {
            let messagingAlert = UIAlertController(title: "Messaging not avaliable", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            messagingAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            present(messagingAlert, animated: true, completion: nil)
        }
    }
}

// MARK: Message Delegate

extension FriendsViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        switch result {
        case .sent:
            FIRAnalytics.logEvent(withName: "inviteSent", parameters: [:])
        default:
            break
        }
    }
}
