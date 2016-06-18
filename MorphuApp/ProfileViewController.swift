//
//  UserViewController.swift
//  Canvi
//
//  Created by Dylan Wight on 6/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import CCBottomRefreshControl

class ProfileViewController: WallViewController {
    
    var userInstance: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.drawingSource = userInstance!.getDrawings
        API.sharedInstance.getFullUser(userInstance!, delagate: self)
    }
    
//    private func setTitle() {
//        
//        let view = self.navigationItem.titleView
//        let button =  UIButton(type: .Custom)
//        button.frame = CGRectMake(0, 0, 200, 40) as CGRect
//        button.addTarget(self, action: #selector(ProfileViewController.scrollToTop(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        view?.addSubview(button)
//
//        self.navigationItem.titleView = button
//    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
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

            profileCell.profileImage.image = userInstance!.profileImage
            profileCell.followingCount.text = String(userInstance!.getFollowing().count)
            profileCell.followersCount.text = String(userInstance!.getFollowers().count)
            profileCell.drawingsCount.text = String(userInstance!.getDrawings().count)
            
            profileCell.followButton.addTarget(self, action: #selector(ProfileViewController.followAction(_:)), forControlEvents: .TouchUpInside)
            
            if userInstance!.userId == api.getActiveUser().userId {
                profileCell.followButton.setImage(nil, forState: .Normal)
                profileCell.followButton.enabled = false
            } else {
                profileCell.followButton.selected = api.getActiveUser().isFollowing(userInstance!)
            }
            
        } else {
            super.tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
        }
    }

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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLikes" {
            let targetController = segue.destinationViewController as! UserListViewController
            targetController.navigationItem.title = "Likes"
            targetController.userSource = { self.userInstance!.getDrawings()[sender!.tag].getLikes() }
        } else if segue.identifier == "showComments" {
            let targetController = segue.destinationViewController as! CommentViewController
            targetController.drawingInstance = userInstance!.getDrawings()[sender!.tag]
        }  else if segue.identifier == "showFollowers" {
            let targetController = segue.destinationViewController as! UserListViewController
            targetController.navigationItem.title = "Followers"
            targetController.userSource = { self.userInstance!.getFollowers() }
        } else if segue.identifier == "showFollowing" {
            let targetController = segue.destinationViewController as! UserListViewController
            targetController.navigationItem.title = "Following"
            targetController.userSource = { self.userInstance!.getFollowing() }
        }
    }

    private func unfollow(sender: UIButton) {
        sender.selected = false
        api.getActiveUser().unfollow(userInstance!)
        api.unfollow(userInstance!)
    }
    
    func addLogoutButton() {
        let chevron = UIImage(named: "Logout")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: chevron, style: .Plain, target: self,                                                                action: #selector(ProfileViewController.logout(_:)))
    }
    
    func logout(sender: UIBarButtonItem) {
        api.clearData()
        AuthAPI.sharedInstance.logout()
        self.performSegueWithIdentifier("logout", sender: self)
    }
}