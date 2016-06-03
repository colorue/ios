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
            let drawing = userInstance!.getDrawings()[indexPath.row]
            let drawingCell = cell as! DrawingCell
            
            drawingCell.drawingImage.image = nil
            
            api.downloadImage(drawing.getDrawingId(),
                              progressCallback: { (progress: Float) -> () in
                                drawingCell.progressBar.setProgress(progress, animated: true)
                },
                              finishedCallback: { (drawingImage: UIImage) -> () in
                                drawingCell.drawingImage.image = drawingImage
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
}