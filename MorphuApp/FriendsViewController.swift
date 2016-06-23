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

class FriendsViewController: UITableViewController, UserCellDelagate, APIDelagate {
    
    lazy var contacts = ContactsAPI()
    let api = API.sharedInstance
    
    let tintColor = blueColor
    
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
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return api.getFacebookFriends().count
        } else {
            return contacts.getLinkedUsers().count
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
            
        } else  {
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
    
    
    // MARK: APIDelagate Methods
    
    func refresh() {
        self.tableView.reloadData()
    }
    
    // MARK: Segues
    
    func addInviteButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Invite", style: .Plain, target: self, action: #selector(FriendsViewController.invite(_:)))
    }
    
    @objc private func invite(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("toInvite", sender: self)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showUser", sender: self)
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
                targetController.tintColor = self.tintColor
                targetController.navigationItem.title = user.username
                targetController.userInstance = user
            }
        }
    }
}