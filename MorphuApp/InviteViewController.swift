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

class InviteViewController: UITableViewController, UserCellDelagate, MFMessageComposeViewControllerDelegate {
    
    lazy var contacts = ContactsAPI()
    let api = API.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return api.getFacebookFriends().count
        } else if section == 1 {
            return contacts.getLinkedUsers().count
        } else {
            return contacts.getContacts().count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as! UserCell
            
            let user = api.getFacebookFriends()[indexPath.row]
            cell.username.text = user.username
            cell.fullName.text = user.fullname
            cell.profileImage.image = user.profileImage
            cell.delagate = self
            cell.user = user
            
            if user.userId == api.getActiveUser().userId {
                cell.followButton.hidden = true
            } else {
                cell.followButton.selected = api.getActiveUser().isFollowing(user)
            }
            
            return cell

        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as! UserCell
            
            let user = contacts.getLinkedUsers()[indexPath.row]
            cell.username.text = user.username
            cell.fullName.text = user.fullname
            cell.profileImage.image = user.profileImage
            cell.delagate = self
            cell.user = user
            
            if user.userId == api.getActiveUser().userId {
                cell.followButton.hidden = true
            } else {
                cell.followButton.selected = api.getActiveUser().isFollowing(user)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("InviteCell")! as! InviteCell
            
            let contact = contacts.getContacts()[indexPath.row]
            
            cell.contactName.text = contact.name
            
            return cell
        }

    }
    
    private func sendInvite(contact: Contact) {
        let controller = MFMessageComposeViewController()

        if (MFMessageComposeViewController.canSendText()) {
            controller.body = "Test"
            controller.recipients = contact.getPhoneNumbers()
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    
    // MARK: UserCellDelagate Methods
    
    func followAction(userCell: UserCell) {
        userCell.followButton.selected = true
        
        api.getActiveUser().follow(userCell.user!)
        api.follow(userCell.user!)
    }
    
    func unfollowAction(userCell: UserCell) {
        if let user = userCell.user {
            let actionSelector = UIAlertController(title: "Unfollow \(user.username)?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSelector.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            actionSelector.addAction(UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.Destructive,
                handler: {(alert: UIAlertAction!) in self.unfollow(userCell)}))
            
            self.presentViewController(actionSelector, animated: true, completion: nil)
        }
    }
    
    private func unfollow(userCell: UserCell) {
        userCell.followButton.selected = false
        api.getActiveUser().unfollow(userCell.user!)
        api.unfollow(userCell.user!)
    }
    
    
    // MARK: MFMessageComposeViewControllerDelegate Methods
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Segues
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            sendInvite(contacts.getContacts()[indexPath.row])
        } else {
            self.performSegueWithIdentifier("showUser", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showUser" {
            let targetController = segue.destinationViewController as! ProfileViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let user: User
                if indexPath.section == 0 {
                    user = api.getFacebookFriends()[indexPath.row]
                } else {
                    user = contacts.getLinkedUsers()[indexPath.row]
                }
                targetController.navigationItem.title = user.username
                targetController.userInstance = user
            }
        }
    }
}