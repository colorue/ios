//
//  HomeTableViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import CCBottomRefreshControl
import Kingfisher
import FBSDKShareKit
import MessageUI
import Firebase

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
        let tag: Int

        if indexPath.section == 0 {
            drawing = api.getDrawingOfTheDay()[0]
            tag = -1
        } else {
            drawing = drawingSource()[indexPath.row]
            tag = indexPath.row
        }
        
        drawingCell.drawing = drawing
        drawingCell.color = tintColor
        drawingCell.delagate = self
        drawingCell.cellTag = tag
        
        if (indexPath.row + 1 >= drawingSource().count) {
            self.loadMoreDrawings?()
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
            targetController.userSource = { return drawing.getLikes() }
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



extension DrawingListViewController: DrawingCellDelagate {
    
    func likeButtonPressed(drawing: Drawing) {
        if !(drawing.liked(api.getActiveUser())) {
            api.like(drawing)
            FIRAnalytics.logEventWithName("likedDrawing", parameters: [:])
        } else {
            api.unlike(drawing)
            FIRAnalytics.logEventWithName("unlikedDrawing", parameters: [:])
        }
    }
    
    
    func presentDrawingActions(drawing: Drawing) {
        
        let drawingActions = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if (drawing.getArtist().userId == api.getActiveUser().userId) {
            drawingActions.addAction(UIAlertAction(title: "Set as Profile Drawing", style: .Default, handler: { (action: UIAlertAction!) in
                self.api.makeProfilePic(drawing)
                FIRAnalytics.logEventWithName("setProfileDrawing", parameters: [:])
            }))
            drawingActions.addAction(UIAlertAction(title: "Share to Facebook", style: .Default, handler: { (action: UIAlertAction!) in
                self.shareToFacebook(drawing)
            }))
            drawingActions.addAction(UIAlertAction(title: "Send as Text", style: .Default, handler: { (action: UIAlertAction!) in
                self.sendDrawing(drawing)
            }))
            drawingActions.addAction(UIAlertAction(title: "Save", style: .Default, handler:  { (action: UIAlertAction!) in
                UIImageWriteToSavedPhotosAlbum(drawing.getImage(), self, nil, nil)
                FIRAnalytics.logEventWithName("ownDrawingSavedFeed", parameters: [:])
            }))
            drawingActions.addAction(UIAlertAction(title: "Edit", style: .Default, handler: { (action: UIAlertAction!) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let activity = storyboard.instantiateViewControllerWithIdentifier("DrawingViewController") as! UINavigationController
                let drawingViewController = activity.topViewController as! DrawingViewController
                drawingViewController.baseImage = drawing.getImage()
                FIRAnalytics.logEventWithName("editDrawing", parameters: [:])
                self.presentViewController(activity, animated: true, completion: nil)
            }))
            drawingActions.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action: UIAlertAction!) in
                let deleteAlert = UIAlertController(title: "Delete drawing?", message: "This drawing will be deleted permanently", preferredStyle: UIAlertControllerStyle.Alert)
                deleteAlert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action: UIAlertAction!) in
                    self.api.deleteDrawing(drawing)
                    FIRAnalytics.logEventWithName("drawingDeleted", parameters: [:])

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
                    FIRAnalytics.logEventWithName("drawingReported", parameters: [:])
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil ))
                self.presentViewController(deleteAlert, animated: true, completion: nil)
            }))
            drawingActions.addAction(UIAlertAction(title: "Save", style: .Default, handler:  { (action: UIAlertAction!) in
                UIImageWriteToSavedPhotosAlbum(drawing.getImage(), self, nil, nil)
                FIRAnalytics.logEventWithName("friendDrawingSavedFeed", parameters: [:])
            }))
        }
        
        if api.getActiveUser().userId == "5Apylh3iA6bDpkDDGwcG3G8BWZ42" {
            drawingActions.addAction(UIAlertAction(title: "Make DOD!", style: .Default, handler:  { (action: UIAlertAction!) in
                self.api.makeDOD(drawing)
            }))
        }
        
        drawingActions.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil ))
        
        self.presentViewController(drawingActions, animated: true, completion: nil)
    }
    
    private func sendDrawing(drawing: Drawing) {
        FIRAnalytics.logEventWithName("sendDrawingClickedFeed", parameters: [:])

        if (MFMessageComposeViewController.canSendText()) {
            controller.addAttachmentData(UIImagePNGRepresentation(drawing.getImage())!, typeIdentifier: "public.data", filename: "colorue.png")
            controller.messageComposeDelegate = self
            controller.resignFirstResponder()
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    private func shareToFacebook(drawing: Drawing) {
        FIRAnalytics.logEventWithName("shareToFacebookClickedFeed", parameters: [:])
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
}

extension DrawingListViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.controller = MFMessageComposeViewController()
    }
}