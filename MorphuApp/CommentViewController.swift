//
//  GroupTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class CommentViewController: UITableViewController {
    
    var drawingInstance = Drawing()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        let chevron = UIImage(named: "ChevronBack")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.tintColor = UIColor.whiteColor()
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        backButton.setImage(chevron, forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(LikeViewController.unwind(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drawingInstance.getComments().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell")! as! CommentCell
        
        let comment = drawingInstance.getComments()[indexPath.row]
        cell.username.text = comment.user.username
        cell.profileImage.image = comment.user.profileImage
        cell.timeStamp.text = comment.getTimeSinceSent()
        cell.commentText.text = comment.text
        return cell
    }
    
    @IBAction func pullRefresh(sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func unwind(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("backToHome", sender: self)
    }
}