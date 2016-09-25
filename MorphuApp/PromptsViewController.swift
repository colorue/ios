//
//  PromptViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 8/6/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//


import UIKit
import Firebase

class PromptsViewController: UITableViewController {
    
    let api = API.sharedInstance
    
    var tintColor = orangeColor
    
    fileprivate var textInputCell: TextInputCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return api.getPrompts().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PromptCell")! as! PromptCell
        cell.prompt = api.getPrompts()[(indexPath as NSIndexPath).row]
        cell.buttonTag = (indexPath as NSIndexPath).row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WriteCommentCell")! as! TextInputCell
        cell.delagate = self
        
        let separatorU = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0.5))
        separatorU.backgroundColor = UIColor.lightGray
        cell.addSubview(separatorU)
        
        cell.textField?.tintColor = self.tintColor
        cell.submitButton?.setTitleColor(self.tintColor, for: UIControlState())
        
        cell.textField?.delegate = cell
        cell.textField?.placeholder = "Create prompt..."

        self.textInputCell = cell
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PromptViewController,
            let row = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
            controller.tintColor = tintColor
            controller.prompt = api.getPrompts()[row]
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    @IBAction func pullRefresh(_ sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}

extension PromptsViewController: TextInputCellDelagate {
    func submit(_ text: String) {
        api.createPrompt(text)
        self.textInputCell?.textField?.text = ""
        FIRAnalytics.logEvent(withName: "submitPrompt", parameters: [:])
        self.tableView.reloadData()
    }
}


// MARK: Edit Cells

extension PromptsViewController {
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return  UITableViewCellEditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt editActionsForRowAtIndexPath: IndexPath) -> [UITableViewRowAction] {
        if api.getPrompts()[(editActionsForRowAtIndexPath as NSIndexPath).row].user.userId == api.getActiveUser().userId {
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { action, indexPath in
                self.setEditing(false, animated: true)
                let deleteAlert = UIAlertController(title: "Delete prompt?", message: "This prompt will be deleted permanently, but its drawings will still exist.", preferredStyle: UIAlertControllerStyle.alert)
                deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                    self.api.deletePrompt(self.api.getPrompts()[(editActionsForRowAtIndexPath as NSIndexPath).row])
                    FIRAnalytics.logEvent(withName: "deletedPrompt", parameters: [:])
                    self.tableView.reloadData()
                }))
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
                self.present(deleteAlert, animated: true, completion: nil)
            })
            return [deleteAction]
        } else {
            let reportAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Report", handler: { action, indexPath in
                let deleteAlert = UIAlertController(title: "Report prompt?", message: "Please report any prompts that are overtly sexual, promote violence, or are intentionally mean-spirited.", preferredStyle: UIAlertControllerStyle.alert)
                deleteAlert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (action: UIAlertAction!) in
                    self.api.reportPrompt(self.api.getPrompts()[(editActionsForRowAtIndexPath as NSIndexPath).row])
                    FIRAnalytics.logEvent(withName: "reportedPrompt", parameters: [:])
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
}
