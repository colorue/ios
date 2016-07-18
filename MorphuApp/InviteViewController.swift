//
//  GroupTableViewController.swift
//  Morphu
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        api.delagate = self
        self.tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return api.getContacts().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("InviteCell")! as! InviteCell
        let contact = api.getContacts()[indexPath.row]
        cell.contactName.text = contact.name
        return cell
    }
    
    private func sendInvite(contact: Contact) {

        if (MFMessageComposeViewController.canSendText()) {
            
            FIRAnalytics.logEventWithName("inviteTextOpened", parameters: [:])

            controller.body = "\(api.getActiveUser().username) invited you to join to Colorue. It's an app for drawing on your iPhone and sharing your creations\nwww.facebook.com/colorueApp/"

            controller.recipients = [contact.getPhoneNumber()!]
            if let image = self.api.getActiveUser().profileImage {
                controller.addAttachmentData(UIImagePNGRepresentation(image)!, typeIdentifier: "public.data", filename: "\(self.api.getActiveUser().username)'s profile.png")
            }
            controller.messageComposeDelegate = self
            self.resignFirstResponder()

            self.presentViewController(controller, animated: true, completion: {
            })
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.sendInvite(api.getContacts()[indexPath.row])
    }

    
    // MARK: MFMessageComposeViewControllerDelegate Methods
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.controller = MFMessageComposeViewController()
    }
    
    // MARK: APIDelagate Methods
    
    func refresh() {
        self.tableView.reloadData()
    }
}