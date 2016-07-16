//
//  HomeTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import CCBottomRefreshControl
import Kingfisher
import FBSDKShareKit
import MessageUI

class DrawingListViewController: UITableViewController, APIDelagate {
    
    // MARK: Properties
    let api = API.sharedInstance
    let bottomRefreshControl = UIRefreshControl()
    var drawingSource = API.sharedInstance.getWall
    
    var controller = MFMessageComposeViewController()

    var tintColor: UIColor?
    
    var loadMoreDrawings: (()->())?
    
    // MARK: Loading Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 586.0
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        self.navigationController?.navigationBar.tintColor = self.tintColor
        
        bottomRefreshControl.triggerVerticalOffset = 50.0
        bottomRefreshControl.addTarget(self, action: #selector(DrawingListViewController.refresh), forControlEvents: .ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        api.delagate = self
        self.refresh()
        
        // bottomRefreshControl needs to be set in viewDidApear
        self.tableView.bottomRefreshControl = bottomRefreshControl
    }
    
    func scrollToTop() {
        if tableView.numberOfRowsInSection(0) > 0 {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        } else if tableView.numberOfRowsInSection(1) > 0 {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 1), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    @IBAction func pullRefresh(sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return drawingSource().count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.tableView.dequeueReusableCellWithIdentifier("DrawingCell", forIndexPath: indexPath) as! DrawingCell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                            forRowAtIndexPath indexPath: NSIndexPath) {
        let drawingCell = cell as! DrawingCell
        let drawing: Drawing

        if indexPath.section == 0 {
            drawing = api.getDrawingOfTheDay()[0]
            self.loadDrawingCell(drawing, drawingCell: drawingCell, tag: -1)
        } else {
            drawing = drawingSource()[indexPath.row]
            self.loadDrawingCell(drawing, drawingCell: drawingCell, tag: indexPath.row)
        }
        
        if (indexPath.row + 1 >= drawingSource().count) {
            self.loadMoreDrawings?()
        }
    }
    
    private func loadDrawingCell(drawing: Drawing, drawingCell: DrawingCell, tag: Int) {
        drawingCell.progressBar.hidden = true
        
        if let url = drawing.url {
            drawingCell.drawingImage.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: [.Transition(.Fade(0.2))],                         completionHandler: { (image, error, cacheType, imageURL) -> () in
                drawing.setImage(image)
            })
        }
        
        drawingCell.profileImage.image = drawing.getArtist().profileImage
        drawingCell.creator.text = drawing.getArtist().username
        drawingCell.timeCreated.text = drawing.getTimeSinceSent()
        drawingCell.likeButton.selected = drawing.liked(api.getActiveUser())
        
        drawingCell.userButton.tag = tag
        drawingCell.uploadButton.tag = tag
        drawingCell.likeButton.tag = tag
        drawingCell.likesButton.tag = tag
        drawingCell.commentsButton.tag = tag
        
        drawingCell.uploadButton.tintColor = tintColor
        drawingCell.likeButton.tintColor = tintColor
        drawingCell.likes.textColor = tintColor
        drawingCell.commentCount.textColor = tintColor
        
        drawingCell.uploadButton.addTarget(self, action: #selector(WallViewController.presentDrawingActions(_:)), forControlEvents: .TouchUpInside)
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
        let drawing = getClickedDrawing(sender)
        
        if !(drawing.liked(api.getActiveUser())) {
            sender.selected = true
            api.like(drawing)
        } else {
            sender.selected = false
            api.unlike(drawing)
        }
        if sender.tag >= 0 {
            self.setLikes(drawing, indexPath: NSIndexPath(forRow: sender.tag, inSection: 1))
        } else {
            self.setLikes(drawing, indexPath: NSIndexPath(forRow: 0, inSection: 0))
        }
    }
    
    @IBAction func refreshPulled(sender: UIRefreshControl) {
        refresh()
    }
    
    func refresh() {
        dispatch_async(dispatch_get_main_queue(), {
            self.bottomRefreshControl.endRefreshing()
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    func presentDrawingActions(sender: UIButton) {
        
        let drawing = getClickedDrawing(sender)
        
        let drawingActions = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if (drawing.getArtist().userId == api.getActiveUser().userId) {
            drawingActions.addAction(UIAlertAction(title: "Set as Profile Drawing", style: .Default, handler: { (action: UIAlertAction!) in
                self.api.makeProfilePic(drawing)
            }))
            drawingActions.addAction(UIAlertAction(title: "Share to Facebook", style: .Default, handler: { (action: UIAlertAction!) in
                self.shareToFacebook(drawing)
            }))
            drawingActions.addAction(UIAlertAction(title: "Send as Text", style: .Default, handler: { (action: UIAlertAction!) in
                self.sendDrawing(drawing)
            }))
            drawingActions.addAction(UIAlertAction(title: "Save", style: .Default, handler:  { (action: UIAlertAction!) in
                UIImageWriteToSavedPhotosAlbum(drawing.getImage(), self, nil, nil)
            }))
            drawingActions.addAction(UIAlertAction(title: "Edit", style: .Default, handler: { (action: UIAlertAction!) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let activity = storyboard.instantiateViewControllerWithIdentifier("DrawingViewController") as! UINavigationController
                let drawingViewController = activity.topViewController as! DrawingViewController
                drawingViewController.baseImage = drawing.getImage()
                self.presentViewController(activity, animated: true, completion: nil)
            }))
            drawingActions.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action: UIAlertAction!) in
                let deleteAlert = UIAlertController(title: "Delete drawing?", message: "This drawing will be deleted permanently", preferredStyle: UIAlertControllerStyle.Alert)
                deleteAlert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action: UIAlertAction!) in
                    self.api.deleteDrawing(drawing)
                    //tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: sender.tag, inSection: 1)], withRowAnimation: .Fade)
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil ))
                self.presentViewController(deleteAlert, animated: true, completion: nil)
            }))
        } else {
            drawingActions.addAction(UIAlertAction(title: "Report", style: .Destructive, handler: { (action: UIAlertAction!) in
                let deleteAlert = UIAlertController(title: "Report drawing?", message: "Please report any drawings that are overtly sexual, promote violence, or are intentionally mean-spirited.", preferredStyle: UIAlertControllerStyle.Alert)
                deleteAlert.addAction(UIAlertAction(title: "Report", style: .Destructive, handler: { (action: UIAlertAction!) in
                    self.api.reportDrawing(drawing)
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil ))
                self.presentViewController(deleteAlert, animated: true, completion: nil)
            }))
            drawingActions.addAction(UIAlertAction(title: "Save", style: .Default, handler:  { (action: UIAlertAction!) in
                UIImageWriteToSavedPhotosAlbum(drawing.getImage(), self, nil, nil)
            }))
        }
        
        drawingActions.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil ))

        self.presentViewController(drawingActions, animated: true, completion: nil)
    }
    
    private func sendDrawing(drawing: Drawing) {
        if (MFMessageComposeViewController.canSendText()) {
            controller.addAttachmentData(UIImagePNGRepresentation(drawing.getImage())!, typeIdentifier: "public.data", filename: "colorue.png")
            controller.messageComposeDelegate = self
            controller.resignFirstResponder()
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    private func shareToFacebook(drawing: Drawing) {
        let content = FBSDKSharePhotoContent()
        let photo = FBSDKSharePhoto(image: drawing.getImage(), userGenerated: true)
        content.photos  = [photo]
        
        let dialog = FBSDKShareDialog()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = FBSDKShareDialogMode.Native
        if !dialog.show() {
            dialog.mode = FBSDKShareDialogMode.Automatic
            dialog.show()
        }
    }
    
    private func getClickedDrawing(sender: AnyObject) -> Drawing {
        if sender.tag >= 0 {
            return drawingSource()[sender.tag]
        } else {
            return api.getDrawingOfTheDay()[0]
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLikes" {
            let drawing = getClickedDrawing(sender!)
            let targetController = segue.destinationViewController as! UserListViewController
            targetController.navigationItem.title = "Likes"
            targetController.tintColor = self.tintColor!
            targetController.userSource = drawing.getLikes()
        } else if segue.identifier == "showComments" {
            let drawing = getClickedDrawing(sender!)
            let targetController = segue.destinationViewController as! CommentViewController
            targetController.tintColor = self.tintColor!
            targetController.drawingInstance = drawing
        } else if segue.identifier == "showUserButton" {
            let drawing = getClickedDrawing(sender!)
            let targetController = segue.destinationViewController as! ProfileViewController
            targetController.navigationItem.title = drawing.getArtist().username
            targetController.tintColor = self.tintColor!
            targetController.userInstance = drawing.getArtist()
        }
    }
    
    override func didReceiveMemoryWarning() {
        api.releaseMemory()
        super.didReceiveMemoryWarning()
    }
}

extension DrawingListViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.controller = MFMessageComposeViewController()
    }
}