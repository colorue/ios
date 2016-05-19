//
//  ThreadTableView.swift
//  Morphu
//
//  Created by Dylan Wight on 4/12/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class ThreadTableViewController: UITableViewController {

    var chainInstance = Chain()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300.0
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        let chevron = UIImage(named: "ChevronBack")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.tintColor = UIColor.whiteColor()
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        backButton.setImage(chevron, forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(ThreadTableViewController.unwindHome(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return chainInstance.getAllContent().count
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let content = chainInstance.getAllContent()[indexPath.row]
            if (content.isDrawing) {
                return self.tableView.dequeueReusableCellWithIdentifier("InboxDrawingCell", forIndexPath: indexPath) as! InboxDrawingCell
            } else {
                return tableView.dequeueReusableCellWithIdentifier("InboxDescriptionCell", forIndexPath: indexPath) as! InboxDescriptionCell
            }
        } else {
            return tableView.dequeueReusableCellWithIdentifier("UpNextCell", forIndexPath: indexPath) as! UpNextCell
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        if indexPath.section == 0 {
            let content = chainInstance.getAllContent()[indexPath.row]
            if (content.isDrawing) {
                let drawingCell = cell as! InboxDrawingCell
                drawingCell.creator.text = content.getAuthor().username
                //drawingCell.actionIcon.image = self.stackIcon
                drawingCell.drawingImage.image = UIImage.fromBase64(content.text)
                drawingCell.timeCreated.text = content.getTimeSinceSent()
            } else {
                let descriptionCell = cell as! InboxDescriptionCell
                descriptionCell.creator.text = content.getAuthor().username
                //descriptionCell.actionIcon.image = self.stackIcon
                descriptionCell.descriptionText.text = content.text
                descriptionCell.timeCreated.text = content.getTimeSinceSent()
            }
        } else {
            let upNextCell = cell as! UpNextCell
            upNextCell.upNextUser.text = chainInstance.getNextUser().username
        }
    }
    
    @IBAction func pullRefresh(sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func unwindHome(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("toHomeTable", sender: self)
    }
}