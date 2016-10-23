//
//  ExploreViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 8/6/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//


import UIKit

class ExploreViewController: DrawingListViewController {
    
    // MARK: - Properties
    
    var searchController = UISearchController(searchResultsController: nil)
    var userSearchSource = API.sharedInstance.getActiveUser().getFollowers().intersection(API.sharedInstance.getActiveUser().getFollowing())
    var filteredUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSearchController()
        
        drawingSource = { return self.api.explore }
        
        loadMoreDrawings = self.api.loadExplore
    }
}

extension ExploreViewController: UISearchResultsUpdating {
    
    fileprivate func setUpSearchController() {
        guard let userListController = R.storyboard.users.users() else { return }
        
        userListController.tintColor = tintColor
        userListController.controller = self
        
        self.searchController = UISearchController(searchResultsController: userListController)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.tintColor = self.tintColor
        self.searchController.searchBar.barTintColor = Theme.white
        self.searchController.searchBar.searchBarStyle = .prominent
        self.searchController.searchBar.placeholder = "Search users..."
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        
        let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textField?.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        
    }
    
    // MARK: UISearchResultsUpdating Methods
    
    func updateSearchResults(for searchController: UISearchController) {
        let userListController = searchController.searchResultsController as! UserListViewController
        
        filterContentForSearchText(searchController.searchBar.text!)
        
        userListController.tintColor = tintColor
        userListController.users = filteredUsers
        userListController.refresh()
    }
    
    fileprivate func filterContentForSearchText(_ searchText: String) {
        filteredUsers = userSearchSource.filter({( user : User) -> Bool in
            return (user.username.lowercased().contains(searchText.lowercased()) || user.fullname.lowercased().contains(searchText.lowercased()))
        })
        
        UserService().search(for: searchText, callback: addToSearch)
    }
    
    fileprivate func addToSearch(_ user: User) {
        userSearchSource.insert(user)
    }
    
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if searchController.isActive {
            let userListController = searchController.searchResultsController as! UserListViewController
            if let targetController = segue.destination as? ProfileViewController {
                if let row = (userListController.tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                    targetController.tintColor = tintColor
                    targetController.navigationItem.title = filteredUsers[row].username
                    targetController.userInstance = filteredUsers[row]
                }
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
