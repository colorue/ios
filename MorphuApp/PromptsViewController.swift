//
//  PromptViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 8/6/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//


import UIKit
import Firebase

class PromptsViewController: UITableViewController, CommentCellDelagate {
    
    let api = API.sharedInstance
    
    var tintColor = orangeColor
    
    private var textInputCell: TextInputCell?
    
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
        return api.getPrompts().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell")! as! CommentCell
        
        let prompt = api.getPrompts()[indexPath.row]
        cell.username.text = prompt.user.username
        cell.profileImage.image = prompt.user.profileImage
        cell.timeStamp.text = prompt.getTimeSinceSent()
        cell.commentText.text = prompt.text
        
        cell.userButton.tag = indexPath.row
        
//        cell.comment = comment
        cell.delagate = self
        
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("WriteCommentCell")! as! TextInputCell
        cell.delagate = self
        
        let separatorU = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5))
        separatorU.backgroundColor = UIColor.lightGrayColor()
        cell.addSubview(separatorU)
        
        cell.textField?.tintColor = self.tintColor
        cell.submitButton?.setTitleColor(self.tintColor, forState: .Normal)
        
        cell.textField?.delegate = cell
        cell.textField?.placeholder = "Create prompt..."

        self.textInputCell = cell
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? PromptViewController,
            let row = tableView.indexPathForSelectedRow?.row {
            controller.tintColor = self.tintColor
            controller.prompt = api.getPrompts()[row]
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    @IBAction func pullRefresh(sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}

extension PromptsViewController: TextInputCellDelagate {
    func submit(text: String) {
        api.createPrompt(text)
        self.textInputCell?.textField?.text = ""
        FIRAnalytics.logEventWithName("submitPrompt", parameters: [:])
        self.tableView.reloadData()
    }
}


// MARK: Edit Cells

extension PromptsViewController {
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return  UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath: NSIndexPath) -> [UITableViewRowAction] {
        if api.getPrompts()[editActionsForRowAtIndexPath.row].user.userId == api.getActiveUser().userId {
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete", handler: { action, indexPath in
                self.setEditing(false, animated: true)
                let deleteAlert = UIAlertController(title: "Delete prompt?", message: "This prompt will be deleted permanently, but its drawings will still exist.", preferredStyle: UIAlertControllerStyle.Alert)
                deleteAlert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action: UIAlertAction!) in
                    self.api.deletePrompt(self.api.getPrompts()[editActionsForRowAtIndexPath.row])
                    FIRAnalytics.logEventWithName("deletedPrompt", parameters: [:])
                    self.tableView.reloadData()
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil ))
                self.presentViewController(deleteAlert, animated: true, completion: nil)
            })
            return [deleteAction]
        } else {
            let reportAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Report", handler: { action, indexPath in
                let deleteAlert = UIAlertController(title: "Report prompt?", message: "Please report any prompts that are overtly sexual, promote violence, or are intentionally mean-spirited.", preferredStyle: UIAlertControllerStyle.Alert)
                deleteAlert.addAction(UIAlertAction(title: "Report", style: .Destructive, handler: { (action: UIAlertAction!) in
                    self.api.reportPrompt(self.api.getPrompts()[editActionsForRowAtIndexPath.row])
                    FIRAnalytics.logEventWithName("reportedPrompt", parameters: [:])
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
}