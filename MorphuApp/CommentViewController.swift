//
//  GroupTableViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Firebase

class CommentViewController: UITableViewController {
    
    let api = API.sharedInstance
    var drawingInstance: Drawing?
    
    var tintColor = redColor
    
    private var writeCommentCell: TextInputCell?
    
    func setDrawingInstance(drawing: Drawing) {
        self.drawingInstance = drawing
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drawingInstance?.getComments().count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.commentCell)!
        cell.comment = drawingInstance?.getComments()[indexPath.row]
        cell.buttonTag = indexPath.row
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.writeCommentCell)!
        cell.delagate = self
        
        let separatorU = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5))
        separatorU.backgroundColor = UIColor.lightGrayColor()
        cell.addSubview(separatorU)
        
        cell.textField?.tintColor = self.tintColor
        cell.submitButton?.setTitleColor(self.tintColor, forState: .Normal)
        
        cell.textField?.delegate = cell
        cell.textField?.placeholder = "Write comment..."
        self.writeCommentCell = cell
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let targetController = segue.destinationViewController as? ProfileViewController {
            targetController.tintColor = self.tintColor
            targetController.navigationItem.title = drawingInstance!.getComments()[sender!.tag].user.username
            targetController.userInstance = drawingInstance!.getComments()[sender!.tag].user
        }
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return  UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath: NSIndexPath) -> [UITableViewRowAction] {
        if drawingInstance?.getComments()[editActionsForRowAtIndexPath.row].user.userId == api.getActiveUser().userId {
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete", handler: { action, indexPath in
                self.setEditing(false, animated: true)
                let deleteAlert = UIAlertController(title: "Delete comment?", message: "This comment will be deleted permanently", preferredStyle: UIAlertControllerStyle.Alert)
                deleteAlert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action: UIAlertAction!) in
                    self.api.deleteComment(self.drawingInstance!, comment: (self.drawingInstance?.getComments()[editActionsForRowAtIndexPath.row])!)
                    Analytics.logEvent(.deletedComment)
                    self.tableView.reloadData()
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil ))
                self.presentViewController(deleteAlert, animated: true, completion: nil)
            })
            return [deleteAction]
        } else {
            let reportAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Report", handler: { action, indexPath in
                let deleteAlert = UIAlertController(title: "Report comment?", message: "Please report any comments that are overtly sexual, promote violence, or are intentionally mean-spirited.", preferredStyle: UIAlertControllerStyle.Alert)
                deleteAlert.addAction(UIAlertAction(title: "Report", style: .Destructive, handler: { (action: UIAlertAction!) in
                    self.api.reportComment((self.drawingInstance?.getComments()[editActionsForRowAtIndexPath.row])!)
                    Analytics.logEvent(.reportedComment)
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil ))
                self.presentViewController(deleteAlert, animated: true, completion: nil)
                self.setEditing(false, animated: true)
            })
            return [reportAction]
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    @IBAction func pullRefresh(sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}

extension CommentViewController: TextInputCellDelagate {
    func submit(text: String) {
        API.sharedInstance.addComment(drawingInstance!, text: text)
        self.writeCommentCell?.textField?.text = ""
        Analytics.logEvent(.wroteComment)
        self.tableView.reloadData()
    }
}