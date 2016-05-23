//
//  HomeTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class WallViewController: UITableViewController, DrawingCellDelagate {
    let model = API.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300.0
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()

        let prefs = NSUserDefaults.standardUserDefaults()
        if (!prefs.boolForKey("getStartedHowTo")) {
            let getStartedHowTo = UIAlertController(title: "Get Started", message: "Send a friend a prompt or drawing to start a new chain.", preferredStyle: UIAlertControllerStyle.Alert)
            getStartedHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(getStartedHowTo, animated: true, completion: nil)
            prefs.setValue(true, forKey: "getStartedHowTo")
        }
        
        if (prefs.boolForKey("notificationsAsk")) {
            let softNotificationAsk = UIAlertController(title: "Enable push notifications?", message: "Find out when someone sends you a prompt or drawing" , preferredStyle: UIAlertControllerStyle.Alert)
            softNotificationAsk.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.Default, handler: enableNotifications))
            //softNotificationAsk.addAction(UIAlertAction(title: "Nope", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(softNotificationAsk, animated: true, completion: nil)
            prefs.setValue(false, forKey: "notificationsAsk")
        }
    }
    
    func enableNotifications(_: UIAlertAction) {
        //UAirship.push()?.userPushNotificationsEnabled = true
    }
    
    func disableNotifactions(_: UIAlertAction) {
        //UAirship.push()?.userPushNotificationsEnabled = false
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
        return model.getWall().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("InboxDrawingCell", forIndexPath: indexPath) as! InboxDrawingCell
        
        if cell.delagate == nil {
            cell.delagate = self
        }
        return cell
    }
        
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                            forRowAtIndexPath indexPath: NSIndexPath) {
        let content = model.getWall()[indexPath.row]
        let drawingCell = cell as! InboxDrawingCell
        drawingCell.profileImage.image = content.getArtist().profileImage
        drawingCell.creator.text = content.getArtist().username
        drawingCell.drawingImage.image = UIImage.fromBase64(content.text)
        drawingCell.timeCreated.text = content.getTimeSinceSent()
    }

    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        _ = tableView.indexPathForSelectedRow!
        self.performSegueWithIdentifier("toThreadTableView", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toThreadTableView" {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! ThreadTableViewController
            let path = tableView.indexPathForSelectedRow
            targetController.chainInstance = model.getArchive()[(path?.item)!]
        }
    }
    */
    
    func like(drawing: Drawing) {
        model.like(drawing)
    }
    
    @IBAction func backToHome(segue: UIStoryboardSegue) {}
}