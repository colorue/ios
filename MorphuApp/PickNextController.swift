//
//  PickNextController.swift
//  Morphu
//
//  Created by Dylan Wight on 5/6/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class PickNextController: UITableViewController {

    let model = API.sharedInstance
    var chainInstance = Chain()
    var avaliableUsers = [User]()
    var unavaliableUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        let chevronDown = UIImage(named: "ChevronDown")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.tintColor = UIColor.whiteColor()
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        backButton.setImage(chevronDown, forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(PickNextController.unwindHome(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        avaliableUsers = model.getUsers().filter({!chainInstance.userIsParticipant($0)})
        unavaliableUsers = model.getUsers().filter({chainInstance.userIsParticipant($0)})
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
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return avaliableUsers.count
        } else if section == 1 {
            return 1
        } else {
            return unavaliableUsers.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")!
            cell.textLabel?.text = avaliableUsers[indexPath.row].username
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("EndChainCell")!
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("UserCellUnavaliable")!
            cell.textLabel?.text = unavaliableUsers[indexPath.row].username
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        _ = tableView.indexPathForSelectedRow!
        if indexPath.section == 0 || indexPath.section == 1 {
            if (chainInstance.getLastContent()!.isDrawing) {
                self.performSegueWithIdentifier("toDescribingView", sender: self)
            } else {
                self.performSegueWithIdentifier("toDrawingView", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDrawingView" {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! DrawingViewController
            targetController.chainInstance = chainInstance
            targetController.descriptionInstance = chainInstance.getLastContent()!
            let path = tableView.indexPathForSelectedRow
            if path?.section == 0 {
                targetController.nextUser = avaliableUsers[(path?.item)!]
            } else {
                targetController.finishChain = true
            }
        } else if segue.identifier == "toDescribingView" {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! DescribingViewController
            targetController.chainInstance = chainInstance
            targetController.drawingInstance = chainInstance.getLastContent()!
            let path = tableView.indexPathForSelectedRow
            if path?.section == 0 {
                targetController.nextUser = avaliableUsers[(path?.item)!]
            } else {
                targetController.finishChain = true
            }
        }
    }
    
    func unwindHome(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("backToInbox", sender: self)
    }
    
    @IBAction func backToPickNext(segue: UIStoryboardSegue) {}
}
