//
//  HomeTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class InboxViewController: UITableViewController {
    let model = API.sharedInstance
    let actionIcon = UIImage(named: "ChevronUp")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300.0
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.reload()
        
        let tabArray = self.tabBarController?.tabBar.items as NSArray!
        model.inboxBadge = tabArray.objectAtIndex(1) as? UITabBarItem
        
        if model.getInbox().count > 0 {
            model.inboxBadge!.badgeValue = String(model.getInbox().count)
        } else {
            model.inboxBadge!.badgeValue = nil
        }
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if (prefs.boolForKey("viewRoundsHowTo")) {
            let viewRoundsHowTo = UIAlertController(title: "See the Full Round", message: "Click on the round in your feed to see what came before" , preferredStyle: UIAlertControllerStyle.Alert)
            viewRoundsHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(viewRoundsHowTo, animated: true, completion: nil)
            prefs.setValue(false, forKey: "viewRoundsHowTo")
        }
    }
    
    @IBAction func pullRefresh(sender: UIRefreshControl) {
        self.reload()
        self.refreshControl?.endRefreshing()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.getInbox().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let content = model.getInbox()[indexPath.row].getLastContent() {
        if (content.isDrawing) {
            return self.tableView.dequeueReusableCellWithIdentifier("InboxDrawingCell", forIndexPath: indexPath) as! InboxDrawingCell
        } else {
            return tableView.dequeueReusableCellWithIdentifier("InboxDescriptionCell", forIndexPath: indexPath) as! InboxDescriptionCell
        }
        } else {
            return tableView.dequeueReusableCellWithIdentifier("InboxDescriptionCell", forIndexPath: indexPath) as! InboxDescriptionCell
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        if let content = model.getInbox()[indexPath.row].getLastContent() {
            if (content.isDrawing) {
                let drawingCell = cell as! InboxDrawingCell
                drawingCell.profileImage.image = content.getAuthor().profileImage
                drawingCell.creator.text = content.getAuthor().username
                drawingCell.actionIcon.image = self.actionIcon
                drawingCell.drawingImage.image = UIImage.fromBase64(content.text)
                drawingCell.timeCreated.text = content.getTimeSinceSent()
            } else {
                let descriptionCell = cell as! InboxDescriptionCell
                descriptionCell.profileImage.image = content.getAuthor().profileImage
                descriptionCell.creator.text = content.getAuthor().username
                descriptionCell.actionIcon.image = self.actionIcon
                descriptionCell.descriptionText.text = content.text
                descriptionCell.timeCreated.text = content.getTimeSinceSent()
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        _ = tableView.indexPathForSelectedRow!
        self.performSegueWithIdentifier("toPickNextController", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toPickNextController" {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! PickNextController
            let path = tableView.indexPathForSelectedRow
            targetController.chainInstance = model.getInbox()[(path?.item)!]
        }
    }
    
    private func reload() {
        self.tableView.reloadData()
        if (model.getInbox().count == 0) {
            self.navigationController?.tabBarItem.badgeValue = nil
        } else {
            self.navigationController?.tabBarItem.badgeValue = String(model.getInbox().count)
        }
    }
    
    @IBAction func backToInbox(segue: UIStoryboardSegue) {}
}