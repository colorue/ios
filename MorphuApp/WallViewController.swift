//
//  HomeTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import CCBottomRefreshControl
import AirshipKit

class WallViewController: DrawingListViewController {

    let prefs = NSUserDefaults.standardUserDefaults()

    // MARK: Loading Methods
    override func viewDidLoad() {
        self.tintColor = redColor
        super.viewDidLoad()
        
        loadMoreDrawings = api.loadWall
        
        self.refreshControl?.beginRefreshing()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!prefs.boolForKey("firstOpen")) {
            prefs.setValue(true, forKey: "firstOpen")
            if let newVC = self.tabBarController!.storyboard?.instantiateViewControllerWithIdentifier("DrawingViewController") {
                self.tabBarController!.presentViewController(newVC, animated: true, completion: nil)
            }
        } else if !prefs.boolForKey("pushAsk1") {
            let pushAsk1 = UIAlertController(title: "Notifications", message: "Want to know if someone follows you or comments on your drawings?", preferredStyle: UIAlertControllerStyle.Alert)
            pushAsk1.addAction(UIAlertAction(title: "Nope", style: UIAlertActionStyle.Default, handler: nil))
            pushAsk1.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { alert in
                UAirship.push().userPushNotificationsEnabled = true
                UAirship.push().namedUser.identifier = self.api.getActiveUser().userId
            }))
            self.presentViewController(pushAsk1, animated: true, completion: nil)
            prefs.setValue(true, forKey: "pushAsk1")
        } else if !UAirship.push().userPushNotificationsEnabled
            && api.getActiveUser().getFollowers().count > 2 {
            UAirship.push().userPushNotificationsEnabled = true
            UAirship.push().namedUser.identifier = self.api.getActiveUser().userId
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return api.getDrawingOfTheDay().count
        } else {
            return drawingSource().count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = self.tableView.dequeueReusableCellWithIdentifier("DrawingCell", forIndexPath: indexPath) as! DrawingCell
        
        if indexPath.section == 0  {
            cell.drawingOfTheDayLabel.hidden = false
        } else {
            cell.drawingOfTheDayLabel.hidden = true
        }
        return cell
    }
    
    @IBAction func backToHome(segue: UIStoryboardSegue) {}
}