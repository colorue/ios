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
            let drawing = userInstance!.getDrawings()[indexPath.row]
            let drawingCell = cell as! DrawingCell
            
            drawingCell.drawingImage.alpha = 0.0
            drawingCell.progressBar.hidden = false
            
            
            api.downloadImage(drawing.getDrawingId(),
                              progressCallback: { (progress: Float) -> () in
                                drawingCell.progressBar.setProgress(progress, animated: true)
                },
                              finishedCallback: { (drawingImage: UIImage) -> () in
                                drawingCell.progressBar.hidden = true
                                drawingCell.drawingImage.image = drawingImage
                                drawing.setImage(drawingImage)
                                
                                UIView.animateWithDuration(0.5,delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                                    drawingCell.drawingImage.alpha = 1.0
                                    }, completion: nil)
            })
            
            drawingCell.profileImage.image = drawing.getArtist().profileImage
            drawingCell.creator.text = drawing.getArtist().username
            drawingCell.timeCreated.text = drawing.getTimeSinceSent()
            drawingCell.likeButton.selected = drawing.liked(api.getActiveUser())
            
            drawingCell.userButton.tag = indexPath.row
            drawingCell.uploadButton.tag = indexPath.row
            drawingCell.likeButton.tag = indexPath.row
            drawingCell.likesButton.tag = indexPath.row
            drawingCell.commentsButton.tag = indexPath.row
            
            drawingCell.uploadButton.addTarget(self, action: #selector(WallViewController.upload(_:)), forControlEvents: .TouchDown)
            drawingCell.likeButton.addTarget(self, action: #selector(WallViewController.likeButtonPressed(_:)), forControlEvents: .TouchDown)
            
            let likes = drawing.getLikes().count
            if likes == 0 {
                drawingCell.likes.text = ""
                drawingCell.likesButton.enabled = false
            } else if likes == 1 {
                drawingCell.likesButton.enabled = true
                drawingCell.likes.text = "1 like"
            } else {
                drawingCell.likesButton.enabled = true
                drawingCell.likes.text = String(likes) + " likes"
            }
            
            if drawing.getComments().count == 1 {
                drawingCell.commentCount.text = "1 comment"
            } else {
                drawingCell.commentCount.text = String(drawing.getComments().count) + " comments"
            }
        }
    }
    
    override func likeButtonPressed(sender: UIButton) {
        let drawing = userInstance!.getDrawings()[sender.tag]
        
        if !(drawing.liked(api.getActiveUser())) {
            sender.selected = true
            api.like(drawing)
        } else {
            sender.selected = false
            api.unlike(drawing)
        }
        self.setLikes(drawing, indexPath: NSIndexPath(forRow: sender.tag, inSection: 1))
    }
    
    override func upload(sender: UIButton) {
        let drawing = userInstance!.getDrawings()[sender.tag]
        let avc = UIActivityViewController(activityItems: [drawing.getImage()], applicationActivities: nil)
        avc.excludedActivityTypes = [UIActivityTypeMail, UIActivityTypePostToVimeo, UIActivityTypePostToFlickr, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop]
        self.presentViewController(avc, animated: true, completion: nil)
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
    
    private func unfollow(sender: UIButton) {
        sender.selected = false
        api.getActiveUser().unfollow(userInstance!)
        api.unfollow(userInstance!)
    }
    
    func addLogoutButton() {
        let chevron = UIImage(named: "Logout")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let logoutButton = UIButton()
        logoutButton.tintColor = UIColor.whiteColor()
        logoutButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        logoutButton.setImage(chevron, forState: UIControlState.Normal)
        logoutButton.addTarget(self, action: #selector(ProfileViewController.logout(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoutButton)
    }
    
    @objc private func logout(sender: UIBarButtonItem) {
        api.logout()
        self.performSegueWithIdentifier("logout", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLikes" {
            let targetController = segue.destinationViewController as! UserListViewController
            targetController.navigationItem.title = "Likes"
            targetController.users = userInstance!.getDrawings()[sender!.tag].getLikes()
        } else if segue.identifier == "showComments" {
            let targetController = segue.destinationViewController as! CommentViewController
            targetController.drawingInstance = userInstance!.getDrawings()[sender!.tag]
        }  else if segue.identifier == "showFollowers" {
            let targetController = segue.destinationViewController as! UserListViewController
            targetController.navigationItem.title = "Followers"
            targetController.users = userInstance!.getFollowers()
        } else if segue.identifier == "showFollowing" {
            let targetController = segue.destinationViewController as! UserListViewController
            targetController.navigationItem.title = "Following"
            targetController.users = userInstance!.getFollowing()
        }
    }
}