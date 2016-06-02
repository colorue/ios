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
            let cell = self.tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! ProfileCell
            cell.profileImage.image = userInstance!.profileImage
            cell.followingCount.text = String(userInstance!.getFollowing().count)
            cell.followersCount.text = String(userInstance!.getFollowers().count)
            cell.drawingsCount.text = String(userInstance!.getDrawings().count)
            
            if userInstance!.userId == api.getActiveUser().userId {
                cell.followButton.setImage(nil, forState: .Normal)
                cell.followButton.enabled = false
            }
            
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("DrawingCell", forIndexPath: indexPath) as! DrawingCell

            return cell
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                            forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            
        } else {
            let content = userInstance!.getDrawings()[indexPath.row]
            let drawingCell = cell as! DrawingCell
            
            
            drawingCell.profileImage.image = content.getArtist().profileImage
            drawingCell.creator.text = content.getArtist().username
            drawingCell.drawingImage.image = content.getImage()
            drawingCell.timeCreated.text = content.getTimeSinceSent()
            drawingCell.likeButton.selected = content.liked(api.getActiveUser())
            

            
            let comments = content.getComments().count
            if comments == 1 {
                drawingCell.commentCount.text = "1 comment"
            } else {
                drawingCell.commentCount.text = String(content.getComments().count) + " comments"
            }
            
//            self.setLikes(drawingCell)
            
            if (indexPath.row + 1 >= api.getWall().count) {
                api.loadWall()
            }
        }
    }

    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLikes" {
            let targetController = segue.destinationViewController as! UserListViewController
            targetController.navigationItem.title = "Likes"
            targetController.users = api.getWall()[sender!.tag].getLikes()
        } else if segue.identifier == "showComments" {
            let targetController = segue.destinationViewController as! CommentViewController
            targetController.drawingInstance = api.getWall()[sender!.tag]
        } else if segue.identifier == "showUser" {
            let targetController = segue.destinationViewController as! ProfileViewController
            targetController.userInstance = api.getWall()[sender!.tag].getArtist()
        }
    }
 
 */
}