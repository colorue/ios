//
//  ChooseGroupController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/26/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class ChooseFirstViewController: UITableViewController  {
    
    let model = API.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        let chevronDown = UIImage(named: "ChevronDown")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.tintColor = UIColor.whiteColor()
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        backButton.setImage(chevronDown, forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(ChooseFirstViewController.unwindHome(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
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
        cell.textLabel?.text = model.getUsers()[indexPath.row].username
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        _ = tableView.indexPathForSelectedRow!
        self.performSegueWithIdentifier("toStartRound", sender: self.parentViewController)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toStartRound" {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! NewThreadViewController
            let path = tableView.indexPathForSelectedRow
            targetController.firstMember = model.getUsers()[(path?.item)!]
        }
    }
    
    func unwindHome(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("backToHome", sender: self)
    }
    
    @IBAction func backToChooseMember(segue: UIStoryboardSegue) {}
}
