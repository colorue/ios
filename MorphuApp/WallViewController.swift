//
//  HomeTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import CCBottomRefreshControl

class WallViewController: UITableViewController, APIDelagate {
    let api = API.sharedInstance
    
    let bottomRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self is ProfileViewController {
            
        } else {
            self.setTitle()
        }

        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 586.0
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        api.delagate = self
        self.refreshControl?.beginRefreshing()
        
        bottomRefreshControl.triggerVerticalOffset = 50.0
        bottomRefreshControl.addTarget(self, action: #selector(WallViewController.refreshBottom(_:)), forControlEvents: .ValueChanged)
    }
    
    func setTitle() {
        let logo = UIImage(named: "Colorue")! // UIImage(named: "Logo Clear")!
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    func refreshBottom(sender: UIRefreshControl) {
        refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
        self.tableView.bottomRefreshControl = bottomRefreshControl // Needs to be in viewDidApear
    }
    
    @IBAction func pullRefresh(sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return api.getWall().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("DrawingCell", forIndexPath: indexPath) as! DrawingCell
        

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                            forRowAtIndexPath indexPath: NSIndexPath) {
        let drawing = api.getWall()[indexPath.row]
        let drawingCell = cell as! DrawingCell
        
        drawingCell.drawingImage.alpha = 0.0
        drawingCell.progressBar.hidden = true

        api.downloadImage(drawing.getDrawingId(),
                          progressCallback: { (progress: Float) -> () in
                            drawingCell.progressBar.setProgress(progress, animated: true)
            },
                          finishedCallback: { (drawingImage: UIImage) -> () in
                            drawingCell.progressBar.hidden = true
                            drawingCell.drawingImage.image = drawingImage
                            drawing.setImage(drawingImage)

                            UIView.animateWithDuration(0.3,delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
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
        
        drawingCell.uploadButton.addTarget(self, action: #selector(WallViewController.upload(_:)), forControlEvents: .TouchUpInside)
        drawingCell.likeButton.addTarget(self, action: #selector(WallViewController.likeButtonPressed(_:)), forControlEvents: .TouchUpInside)

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
        
        if (indexPath.row + 1 >= api.getWall().count) {
            api.loadWall()
        }
    }
    
    func setLikes(drawing: Drawing, indexPath: NSIndexPath) {
        
        let drawingCell = tableView.cellForRowAtIndexPath(indexPath) as! DrawingCell
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
    }
    
    func likeButtonPressed(sender: UIButton) {
        let drawing = api.getWall()[sender.tag]

        if !(drawing.liked(api.getActiveUser())) {
            sender.selected = true
            api.like(drawing)
        } else {
            sender.selected = false
            api.unlike(drawing)
        }
        self.setLikes(drawing, indexPath: NSIndexPath(forRow: sender.tag, inSection: 0))
    }
    
    func refresh() {
        dispatch_async(dispatch_get_main_queue(), {
            self.bottomRefreshControl.endRefreshing()
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    func upload(sender: UIButton) {
        
        let drawing = api.getWall()[sender.tag]
        let avc: UIActivityViewController
        
        if drawing.getArtist().userId == api.getActiveUser().userId {
            let editActivity = EditActivity()
            let deleteActivity = DeleteActivity()
            avc = UIActivityViewController(activityItems: [drawing.getImage(), drawing], applicationActivities: [editActivity, deleteActivity])
        } else {
            avc = UIActivityViewController(activityItems: [drawing.getImage(), drawing], applicationActivities: nil)
        }
        
        avc.excludedActivityTypes = [UIActivityTypeMail, UIActivityTypePostToVimeo, UIActivityTypePostToFlickr, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop]
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
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
            targetController.navigationItem.title = api.getWall()[sender!.tag].getArtist().username
            targetController.userInstance = api.getWall()[sender!.tag].getArtist()
        }
    }
    
    @IBAction func backToHome(segue: UIStoryboardSegue) {}
}