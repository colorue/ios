//
//  GroupTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class UserListViewController: UITableViewController, UserCellDelagate, APIDelagate {
    
    
    var userSource: () -> [User] = API.sharedInstance.getFacebookFriends

    let api = API.sharedInstance
    
    var tintColor = purpleColor

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.tableView.reloadData()
        
        api.delagate = self
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userSource().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as! UserCell
        
        let user = userSource()[indexPath.row]
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
    
    @IBAction func pullRefresh(sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func refresh() {
        print("delagate called refresh")
        self.tableView.reloadData()
//        self.refreshControl?.endRefreshing()
    }
    
    func addInviteButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Invite", style: .Plain, target: self, action: #selector(UserListViewController.invite(_:)))
    }
    
    // MARK: Segue Methods
    
    @objc private func invite(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("toInvite", sender: self)
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showUser", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showUser" {
            let targetController = segue.destinationViewController as! ProfileViewController
            if let row = tableView.indexPathForSelectedRow?.row {
                targetController.tintColor = self.tintColor
                targetController.navigationItem.title = userSource()[row].username
                targetController.userInstance = userSource()[row]
            }
        }
    }
}