//
//  GroupTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class UserListViewController: UITableViewController {
    
    var userSource: () -> [User] = API.sharedInstance.getFriends
    
    let api = API.sharedInstance
    
    var tintColor = blueColor
    
    var controller: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if controller == nil {
            controller = self
        }
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.tableView.reloadData()
        api.delagate = self
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
        cell.delagate = self
        cell.color = self.tintColor
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                            forRowAtIndexPath indexPath: NSIndexPath) {
        if let userCell = cell as? UserCell {
            userCell.user = userSource()[indexPath.row]
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 52.0
    }
    
    @IBAction func pullRefresh(sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}

extension UserListViewController: APIDelagate {
    func refresh() {
        self.tableView.reloadData()
    }
}

extension UserListViewController: UserCellDelagate {
    
    func followAction(userCell: UserCell) {
        userCell.followButton?.selected = true
        
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
        userCell.followButton?.selected = false
        api.getActiveUser().unfollow(userCell.user!)
        api.unfollow(userCell.user!)
    }
}

extension UserListViewController {
    
    // MARK: Segue Methods

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.controller!.performSegueWithIdentifier("showUser", sender: self)
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