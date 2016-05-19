//
//  NewGroupTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class NewGroupTableViewController: UITableViewController {
    
    /*
    let model = API.sharedInstance
    var groupInstance = Group()
    
    var newGroupCell: NewGroupTableCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
        
        let chevron = UIImage(named: "ChevronDown")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.tintColor = UIColor.whiteColor()
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        backButton.setImage(chevron, forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(GroupTableViewController.unwindToGroups(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        groupInstance.addMember(model.getActiveUser())
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func unwindToGroups(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindToGroups", sender: self)
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
        return model.getUsers().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")!
        cell.textLabel?.text = model.getUsers()[indexPath.row ].email
        cell.accessoryType = .None
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.newGroupCell = tableView.dequeueReusableCellWithIdentifier("NewGroupCell") as? NewGroupTableCell
        self.newGroupCell!.groupMembers.lineBreakMode = .ByWordWrapping
        self.newGroupCell!.groupMembers.numberOfLines = 0
        
        self.setMembersNames()
        
        return newGroupCell!
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.cellForRowAtIndexPath(indexPath)!.accessoryType = .Checkmark
        groupInstance.addMember(model.getUsers()[indexPath.row])
        setMembersNames()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.cellForRowAtIndexPath(indexPath)!.accessoryType = .None
        groupInstance.removeMember(model.getUsers()[indexPath.row])
        setMembersNames()
    }
    
    func setMembersNames() {
        var members = ""
        for user in groupInstance.getMembers() {
            members += user.email + ", "
        }
        self.newGroupCell!.groupMembers.text = members
    }
    
    @IBAction func createGroup(sender: UIBarButtonItem) {
        self.groupInstance.setName(self.newGroupCell!.groupName.text!)
        self.model.createGroup(self.groupInstance)
        self.performSegueWithIdentifier("unwindToGroups", sender: self)
    }
 */

}