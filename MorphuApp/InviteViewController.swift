//
//  GroupTableViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Contacts
import MessageUI
import Firebase

class InviteViewController: UITableViewController, MFMessageComposeViewControllerDelegate, APIDelagate {
    
    let api = API.sharedInstance
    
    let tintColor = blueColor
    
    var controller = MFMessageComposeViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        api.delagate = self
        self.tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return api.getContacts().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCell")! as! InviteCell
        let contact = api.getContacts()[(indexPath as NSIndexPath).row]
        cell.contactName.text = contact.name
        return cell
    }
    
    fileprivate func sendInvite(_ contact: Contact) {

        if (MFMessageComposeViewController.canSendText()) {
            
            FIRAnalytics.logEvent(withName: "inviteTextOpened", parameters: [:])

            controller.body = "\(api.getActiveUser().username) invited you to join to Colorue. It's an app for drawing on your iPhone and sharing your creations\nwww.facebook.com/colorueApp/"

            controller.recipients = [contact.getPhoneNumber()!]
            if let image = self.api.getActiveUser().profileImage {
                controller.addAttachmentData(UIImagePNGRepresentation(image)!, typeIdentifier: "public.data", filename: "\(self.api.getActiveUser().username)'s profile.png")
            }
            controller.messageComposeDelegate = self
            self.resignFirstResponder()

            self.present(controller, animated: true, completion: {
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.sendInvite(api.getContacts()[(indexPath as NSIndexPath).row])
    }

    
    // MARK: MFMessageComposeViewControllerDelegate Methods
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        self.controller = MFMessageComposeViewController()
    }
    
    // MARK: APIDelagate Methods
    
    func refresh() {
        self.tableView.reloadData()
    }
}
