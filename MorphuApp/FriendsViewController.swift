//
//  GroupTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class GroupTableViewController: UITableViewController, UserCellDelagate {
    
    let api = API.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return api.getUsers().count
    }
        
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as! UserCell
        
        let user = api.getUsers()[indexPath.row]
        cell.username.text = user.username
        cell.profileImage.image = user.profileImage
        cell.delagate = self
        cell.user = user
        cell.followButton.selected = api.getActiveUser().isFollowing(user)

        return cell
    }
    
    func followAction(userCell: UserCell) {
        userCell.followButton.selected = true
        if let user = userCell.user {
            api.getActiveUser().follow(user)
            api.follow(user)
        }
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
        if let user = userCell.user {
            api.getActiveUser().unfollow(user)
            api.unfollow(user)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("viewFriend", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewFriend" {
            let targetController = segue.destinationViewController as! UserViewController
            if let row = tableView.indexPathForSelectedRow?.row {
                targetController.userInstance = api.getUsers()[row]
            }
        }
    }
    
    @IBAction func pullRefresh(sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    @IBAction func logout(sender: UIBarButtonItem) {
        api.logout()
        self.performSegueWithIdentifier("toLogin", sender: self)
    }
    
    @IBAction func backToFriends(segue: UIStoryboardSegue) {}

}