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
    
    var contacts: [CNContact] = []
    
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
        
        let contactStore = CNContactStore()
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName)]

        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            print("Error fetching containers")
        }
        
        
        // Loop the containers
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                // Put them into "contacts"
                contacts.appendContentsOf(containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }

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
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell")!
        
        let contact = contacts[indexPath.row]
        
        cell.textLabel?.text = contact.givenName + " " + contact.familyName
        return cell
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        }

}