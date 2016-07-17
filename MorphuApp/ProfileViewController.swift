//
//  UserViewController.swift
//  Canvi
//
//  Created by Dylan Wight on 6/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import CCBottomRefreshControl

class ProfileViewController: DrawingListViewController {
    
    var userInstance: User?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawingSource = userInstance!.getDrawings
        API.sharedInstance.loadFulUser(userInstance!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let prefs = NSUserDefaults.standardUserDefaults()
        if (!prefs.boolForKey("firstProfileView")) && userInstance?.userId == API.sharedInstance.getActiveUser().userId {
            prefs.setValue(true, forKey: "firstProfileView")
            
            let firstProfileView = UIAlertController(title: "Set your profile drawing", message: "Press ↥ to upload, download, edit, or set a drawing as your profile picture" , preferredStyle: UIAlertControllerStyle.Alert)
            firstProfileView.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(firstProfileView, animated: true, completion: nil)
        }
    }
}


// MARK: - Table view data source

extension ProfileViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return userInstance!.getDrawings().count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return self.tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! ProfileCell
        } else {
            return self.tableView.dequeueReusableCellWithIdentifier("DrawingCell", forIndexPath: indexPath) as! DrawingCell
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                            forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            let profileCell = cell as! ProfileCell
            profileCell.user = userInstance
            profileCell.color = tintColor ?? redColor
            profileCell.delagate = self
        } else {
            super.tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
        }
    }
}

extension ProfileViewController: ProfileCellDelagate {
    func followAction(sender: UIButton) {
        
        if !sender.selected {
            sender.selected = true
            api.getActiveUser().follow(userInstance!)
            api.follow(userInstance!)
        } else {
            let actionSelector = UIAlertController(title: "Unfollow \(userInstance!.username)?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSelector.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            actionSelector.addAction(UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.Destructive,
                handler: {(alert: UIAlertAction!) in self.unfollow(sender)}))
            
            self.presentViewController(actionSelector, animated: true, completion: nil)
        }
    }
    
    private func unfollow(sender: UIButton) {
        sender.selected = false
        api.getActiveUser().unfollow(userInstance!)
        api.unfollow(userInstance!)
    }
}


// MARK: Segues

extension ProfileViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "showFollowers" {
            let targetController = segue.destinationViewController as! UserListViewController
            targetController.tintColor = self.tintColor!
            targetController.navigationItem.title = "Followers"
            targetController.userSource = Array(self.userInstance!.getFollowers())
        } else if segue.identifier == "showFollowing" {
            let targetController = segue.destinationViewController as! UserListViewController
            targetController.tintColor = self.tintColor!
            targetController.navigationItem.title = "Following"
            targetController.userSource = Array(self.userInstance!.getFollowing())
        }
    }
    
    func addLogoutButton() {
        let chevron = UIImage(named: "Logout")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: chevron, style: .Plain, target: self,                                                                action: #selector(ProfileViewController.logoutPopup(_:)))
    }
    
    func logoutPopup(sender: UIBarButtonItem) {
        
        let logoutConfirm = UIAlertController(title: "Log out?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        logoutConfirm.addAction(UIAlertAction(title: "Log out", style: .Destructive, handler: { (action: UIAlertAction!) in
            self.api.clearData()
            AuthAPI.sharedInstance.logout()
            self.performSegueWithIdentifier("logout", sender: self)
        }))
        
        logoutConfirm.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil ))
        self.presentViewController(logoutConfirm, animated: true, completion: nil)
    }
}