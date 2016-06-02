//
//  HomeTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import CCBottomRefreshControl

class WallViewController: UITableViewController, DrawingCellDelagate, APIDelagate {
    let api = API.sharedInstance
    
    var selectedDrawing = Drawing()
    let bottomRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets appDelagate as delagate for tabView controller
        self.tabBarController?.delegate = UIApplication.sharedApplication().delegate as? UITabBarControllerDelegate
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 586.0
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        api.delagate = self
        self.refreshControl!.beginRefreshing()
        
        bottomRefreshControl.triggerVerticalOffset = 50.0
        bottomRefreshControl.addTarget(self, action: #selector(WallViewController.refreshBottom(_:)), forControlEvents: .ValueChanged)
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
            api.loadWall()
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
            self.bottomRefreshControl.endRefreshing()
            self.refreshControl!.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    func upload(drawingCell: DrawingCell) {
        if let drawing = drawingCell.drawing {
            let avc = UIActivityViewController(activityItems: [drawing.getImage()], applicationActivities: nil)
            avc.excludedActivityTypes = [UIActivityTypeMail, UIActivityTypePostToVimeo, UIActivityTypePostToFlickr, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop]
            self.presentViewController(avc, animated: true, completion: nil)
        }
    }
    
    func viewLikes(drawingCell: DrawingCell) {
        self.selectedDrawing = drawingCell.drawing!
    }
    
    func viewComments(drawingCell: DrawingCell) {
        self.selectedDrawing = drawingCell.drawing!
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toViewLikes" {
            let targetController = segue.destinationViewController as! LikeViewController
            targetController.drawingInstance = self.selectedDrawing
        } else if segue.identifier == "toViewComments" {
            let targetController = segue.destinationViewController as! CommentViewController
            targetController.drawingInstance = self.selectedDrawing
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToHome(segue: UIStoryboardSegue) {}
}