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

class InviteViewController: UITableViewController, MFMessageComposeViewControllerDelegate, APIDelagate {
    
    lazy var contacts = ContactsAPI()
    let api = API.sharedInstance
    
    let tintColor = blueColor
    
    let controller = MFMessageComposeViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        api.delagate = self
        self.tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.getContacts().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("InviteCell")! as! InviteCell
        let contact = contacts.getContacts()[indexPath.row]
        cell.contactName.text = contact.name
        return cell
    }
    
    private func sendInvite(contact: Contact) {
        if (MFMessageComposeViewController.canSendText()) {
            controller.body = "\(api.getActiveUser().username) invited you to join the Colorue beta test:\nhttps://goo.gl/i0Kpmf\nIt's an iOS app for easily drawing on your phone and sharing your creations"
            if let image = api.getActiveUser().profileImage {
                controller.addAttachmentData(UIImagePNGRepresentation(image)!, typeIdentifier: "public.data", filename: "\(api.getActiveUser().username)'s profile.png")
            }
            controller.recipients = [contact.getPhoneNumber()!]
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.sendInvite(contacts.getContacts()[indexPath.row])
    }

    
    // MARK: MFMessageComposeViewControllerDelegate Methods
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: APIDelagate Methods
    
    func refresh() {
        self.tableView.reloadData()
    }
}