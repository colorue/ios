//
//  GroupTableViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Contacts

class InviteViewController: UITableViewController, UISearchBarDelegate {
    
    lazy var contacts = Contacts()
    let api = API.sharedInstance
    
    let searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.frame = CGRectMake(0, 0, self.view.frame.width - 85, 20)
        
        searchBar.placeholder = "Search contacts"
        
        let searchBarItem = UIBarButtonItem(customView:searchBar)
        
        self.navigationItem.leftBarButtonItem = searchBarItem
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        searchBar.delegate = self
        
        let cancelSearchBarButtonItem = UIBarButtonItem(title: "Invite", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationItem.setRightBarButtonItem(cancelSearchBarButtonItem, animated: true)
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        

        return true
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return contacts.getLinkedUsers().count
        } else {
            return contacts.getContacts().count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as! UserCell
            
            let user = contacts.getLinkedUsers()[indexPath.row]
            cell.username.text = user.username
            cell.fullName.text = user.fullname
            cell.profileImage.image = user.profileImage
//            cell.delagate = self
            cell.user = user
            
            if user.userId == api.getActiveUser().userId {
                cell.followButton.hidden = true
            } else {
                cell.followButton.selected = api.getActiveUser().isFollowing(user)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell")!
            
            let contact = contacts.getContacts()[indexPath.row]
            
            
            cell.textLabel?.text = contact.getPhoneNumbers()[0]
            
            return cell
        }

    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}