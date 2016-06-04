//
//  SearchViewController.swift
//  Canvix
//
//  Created by Dylan Wight on 6/4/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
    
    @IBAction func cancelButton(sender: UIBarButtonItem) {
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = UISearchBar(frame: CGRectMake(0, 0, 250, 20))

        searchBar.placeholder = "Search coming soon..."
        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
    }
}