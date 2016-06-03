//
//  GroupTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class CommentViewController: UITableViewController, WriteCommentCellDelagate, CommentCellDelagate {
    
    var drawingInstance: Drawing?
    private var writeCommentCell: WriteCommentCell?
    
    
    func setDrawingInstance(drawing: Drawing) {
        self.drawingInstance = drawing
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
    }
    
    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let drawing = drawingInstance {
            return drawing.getComments().count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell")! as! CommentCell
        
        let comment = drawingInstance!.getComments()[indexPath.row]
        cell.username.text = comment.user.username
        cell.profileImage.image = comment.user.profileImage
        cell.timeStamp.text = comment.getTimeSinceSent()
        cell.commentText.text = comment.text
        
        cell.userButton.tag = indexPath.row
        
        cell.comment = comment
        cell.delagate = self


        return cell
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("WriteCommentCell")! as! WriteCommentCell
        cell.delagate = self
        
        let separatorU = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5))
        separatorU.backgroundColor = dividerColor
        cell.addSubview(separatorU)
        
        self.writeCommentCell = cell
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showUser" {
            let targetController = segue.destinationViewController as! ProfileViewController
            targetController.navigationItem.title = drawingInstance!.getComments()[sender!.tag].user.username
            targetController.userInstance = drawingInstance!.getComments()[sender!.tag].user
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func addComment(text: String) {
        API.sharedInstance.addComment(drawingInstance!, text: text)
        self.writeCommentCell?.commentText.text = ""
        self.tableView.reloadData()
    }
    
    @IBAction func pullRefresh(sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}