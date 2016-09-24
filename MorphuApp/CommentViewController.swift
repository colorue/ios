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
    
    fileprivate var writeCommentCell: TextInputCell?
    
    func setDrawingInstance(_ drawing: Drawing) {
        self.drawingInstance = drawing
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drawingInstance?.getComments().count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.commentCell)!
        cell.comment = drawingInstance?.getComments()[(indexPath as NSIndexPath).row]
        cell.buttonTag = (indexPath as NSIndexPath).row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.writeCommentCell)!
        cell.delagate = self
        
        let separatorU = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5))
        separatorU.backgroundColor = UIColor.lightGray
        cell.addSubview(separatorU)
        
        cell.textField?.tintColor = self.tintColor
        cell.submitButton?.setTitleColor(self.tintColor, for: UIControlState())
        
        cell.textField?.delegate = cell
        cell.textField?.placeholder = "Write comment..."
        self.writeCommentCell = cell
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let targetController = segue.destination as? ProfileViewController {
            targetController.tintColor = self.tintColor
            targetController.navigationItem.title = drawingInstance!.getComments()[(sender! as AnyObject).tag].user.username
            targetController.userInstance = drawingInstance!.getComments()[(sender! as AnyObject).tag].user
        }
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return  UITableViewCellEditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt editActionsForRowAtIndexPath: IndexPath) -> [UITableViewRowAction] {
        if drawingInstance?.getComments()[(editActionsForRowAtIndexPath as NSIndexPath).row].user.userId == api.getActiveUser().userId {
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { action, indexPath in
                self.setEditing(false, animated: true)
                let deleteAlert = UIAlertController(title: "Delete comment?", message: "This comment will be deleted permanently", preferredStyle: UIAlertControllerStyle.alert)
                deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                    self.api.deleteComment(self.drawingInstance!, comment: (self.drawingInstance?.getComments()[(editActionsForRowAtIndexPath as NSIndexPath).row])!)
                    Analytics.logEvent(.deletedComment)
                    self.tableView.reloadData()
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
                self.present(deleteAlert, animated: true, completion: nil)
            })
            return [deleteAction]
        } else {
            let reportAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Report", handler: { action, indexPath in
                let deleteAlert = UIAlertController(title: "Report comment?", message: "Please report any comments that are overtly sexual, promote violence, or are intentionally mean-spirited.", preferredStyle: UIAlertControllerStyle.alert)
                deleteAlert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (action: UIAlertAction!) in
                    self.api.reportComment((self.drawingInstance?.getComments()[(editActionsForRowAtIndexPath as NSIndexPath).row])!)
                    Analytics.logEvent(.reportedComment)
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
                self.present(deleteAlert, animated: true, completion: nil)
                self.setEditing(false, animated: true)
            })
            return [reportAction]
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    @IBAction func pullRefresh(_ sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}

extension CommentViewController: TextInputCellDelagate {
    func submit(_ text: String) {
        API.sharedInstance.addComment(drawingInstance!, text: text)
        self.writeCommentCell?.textField?.text = ""
        Analytics.logEvent(.wroteComment)
        self.tableView.reloadData()
    }
}
