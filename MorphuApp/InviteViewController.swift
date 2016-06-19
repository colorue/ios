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

class InviteViewController: UITableViewController, UISearchBarDelegate, MFMessageComposeViewControllerDelegate {
    
    lazy var contacts = ContactsAPI()
    let api = API.sharedInstance
    
    let searchBar = UISearchBar()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.frame = CGRectMake(0, 0, self.view.frame.width - 85, 20)
        
        searchBar.placeholder = "Search contacts"
        
        let searchBarItem = UIBarButtonItem(customView:searchBar)
        
        self.navigationItem.leftBarButtonItem = searchBarItem
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        searchBar.delegate = self
        
        let cancelSearchBarButtonItem = UIBarButtonItem(title: "Invite", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationItem.setRightBarButtonItem(cancelSearchBarButtonItem, animated: true)
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        

        return true
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
            //            cell.delagate = self
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
//            cell.delagate = self
            cell.user = user
            
            if user.userId == api.getActiveUser().userId {
                cell.followButton.hidden = true
            } else {
                cell.followButton.selected = api.getActiveUser().isFollowing(user)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell")!
            
            let contact = contacts.getContacts()[indexPath.row]
            
            
            cell.textLabel?.text = contact.name
            
            return cell
        }

    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell")!
        headerCell.backgroundColor = backgroundColor
        
        switch (section) {
        case 0:
            headerCell.textLabel?.text = "Facebook Friends";
        //return sectionHeaderView
        case 1:
            headerCell.textLabel?.text = "Contacts";
        //return sectionHeaderView
        case 2:
            headerCell.textLabel?.text = "Invite";
        //return sectionHeaderView
        default:
            headerCell.textLabel?.text = "Other";
        }
        
        return headerCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            sendInvite(contacts.getContacts()[indexPath.row])
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
    
    // MARK: MFMessageComposeViewControllerDelegate Methods
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}