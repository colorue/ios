//
//  GroupTableViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Firebase

class UserListViewController: UITableViewController {
    
    var userSource: () -> [User] = API.sharedInstance.getFriends
    
    let api = API.sharedInstance
    
    var tintColor: UIColor? = blueColor
    
    var controller: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if controller == nil {
            controller = self
        }
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.tableView.reloadData()
        api.delagate = self
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userSource().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userCell)!
        cell.delagate = self
        cell.color = self.tintColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let userCell = cell as? UserCell {
            userCell.user = userSource()[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
    
    @IBAction func pullRefresh(_ sender: UIRefreshControl) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}

extension UserListViewController: APIDelagate {
    func refresh() {
        self.tableView.reloadData()
    }
}

extension UserListViewController: UserCellDelagate {
    
    func followAction(_ userCell: UserCell) {
        userCell.followButton?.isSelected = true
        
        api.getActiveUser().follow(userCell.user!)
        UserService().follow(userCell.user!)
        FIRAnalytics.logEvent(withName: "followedUser", parameters: [:])
    }
    
    func unfollowAction(_ userCell: UserCell) {
        if let user = userCell.user {
            let actionSelector = UIAlertController(title: "Unfollow \(user.username)?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            actionSelector.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            actionSelector.addAction(UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.destructive,
                handler: {(alert: UIAlertAction!) in self.unfollow(userCell)}))
            
            self.present(actionSelector, animated: true, completion: nil)
        }
    }
    
    fileprivate func unfollow(_ userCell: UserCell) {
        userCell.followButton?.isSelected = false
        api.getActiveUser().unfollow(userCell.user!)
        UserService().unfollow(userCell.user!)
        FIRAnalytics.logEvent(withName: "unfollowedUser", parameters: [:])
    }
}

extension UserListViewController {
    
    // MARK: Segue Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.controller!.performSegue(withIdentifier: "showUser", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUser" {
            let targetController = segue.destination as! ProfileViewController
            if let row = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                targetController.tintColor = self.tintColor
                targetController.navigationItem.title = userSource()[row].username
                targetController.userInstance = userSource()[row]
            }
        }
    }
}
