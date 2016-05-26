//
//  HomeTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class WallViewController: UITableViewController, DrawingCellDelagate, APIDelagate {
    let api = API.sharedInstance
    
    var selectedDrawing = Drawing()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 586.0
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        api.delagate = self
        self.refreshControl!.beginRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()

        let prefs = NSUserDefaults.standardUserDefaults()
        if (!prefs.boolForKey("getStartedHowTo")) {
            let getStartedHowTo = UIAlertController(title: "Get Started", message: "Send a friend a prompt or drawing to start a new chain.", preferredStyle: UIAlertControllerStyle.Alert)
            getStartedHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(getStartedHowTo, animated: true, completion: nil)
            prefs.setValue(true, forKey: "getStartedHowTo")
        }
        
        if (prefs.boolForKey("notificationsAsk")) {
            let softNotificationAsk = UIAlertController(title: "Enable push notifications?", message: "Find out when someone sends you a prompt or drawing" , preferredStyle: UIAlertControllerStyle.Alert)
            softNotificationAsk.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.Default, handler: enableNotifications))
            //softNotificationAsk.addAction(UIAlertAction(title: "Nope", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(softNotificationAsk, animated: true, completion: nil)
            prefs.setValue(false, forKey: "notificationsAsk")
        }
    }
    
    func enableNotifications(_: UIAlertAction) {
        //UAirship.push()?.userPushNotificationsEnabled = true
    }
    
    func disableNotifactions(_: UIAlertAction) {
        //UAirship.push()?.userPushNotificationsEnabled = false
    }
    
    @IBAction func pullRefresh(sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return api.getWall().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("InboxDrawingCell", forIndexPath: indexPath) as! DrawingCell
        
        if cell.delagate == nil {
            cell.delagate = self
        }
        return cell
    }
        
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                            forRowAtIndexPath indexPath: NSIndexPath) {
        let content = api.getWall()[indexPath.row]
        let drawingCell = cell as! DrawingCell
        
        content.delagate = drawingCell

        drawingCell.drawing = content
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
        
        self.setLikes(drawingCell)
        
        if (indexPath.row + 1 >= api.getWall().count) {
            print("load more")
            api.loadWallOlder()
        }
    }
    
    private func setLikes(drawingCell: DrawingCell) {
        if let drawing = drawingCell.drawing {
            let likes = drawing.getLikes().count
            if likes == 0 {
                drawingCell.likes.text = ""
                drawingCell.likeCount.enabled = false
            } else if likes == 1 {
                drawingCell.likeCount.enabled = true
                drawingCell.likes.text = "1 like"
            } else {
                drawingCell.likeCount.enabled = true
                drawingCell.likes.text = String(likes) + " likes"
            }
        }
    }
    
    func like(drawingCell: DrawingCell) {
        if let drawing = drawingCell.drawing {
            api.like(drawing)
            self.setLikes(drawingCell)
        }
    }
    
    func unlike(drawingCell: DrawingCell) {
        if let drawing = drawingCell.drawing {
            api.unlike(drawing)
            self.setLikes(drawingCell)
        }
    }
    
    func refresh() {
        dispatch_async(dispatch_get_main_queue(), {
            self.refreshControl!.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    func upload(drawingCell: DrawingCell) {
        if let drawing = drawingCell.drawing {
            let actionSelector = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSelector.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            actionSelector.addAction(UIAlertAction(title: "Save to photos", style: UIAlertActionStyle.Default,
                handler: {(alert: UIAlertAction!) in self.saveDrawing(drawing)}))
            
            self.presentViewController(actionSelector, animated: true, completion: nil)
        }
    }
    
    func viewLikes(drawingCell: DrawingCell) {
        if let drawing = drawingCell.drawing {
            self.selectedDrawing = drawing
        }
        self.performSegueWithIdentifier("toViewLikes", sender: self)
    }
    
    func viewComments(drawingCell: DrawingCell) {
        if let drawing = drawingCell.drawing {
            self.selectedDrawing = drawing
        }
        self.performSegueWithIdentifier("toViewComments", sender: self)
    }
    
    private func saveDrawing(drawing: Drawing) {
        UIImageWriteToSavedPhotosAlbum(drawing.getImage(), nil, nil, nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toViewLikes" {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! LikeViewController
            targetController.drawingInstance = self.selectedDrawing
        } else if segue.identifier == "toViewComments" {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! CommentViewController
            targetController.drawingInstance = self.selectedDrawing
        }
    }
    
    @IBAction func backToHome(segue: UIStoryboardSegue) {}
}