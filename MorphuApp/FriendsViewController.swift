//
//  FriendsViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

class FriendsViewController: UserListViewController {
    
    // MARK: - Properties
    
    var searchController = UISearchController(searchResultsController: nil)
    var userSearchSource = API.sharedInstance.getActiveUser().getFollowers().intersect(API.sharedInstance.getActiveUser().getFollowing())
    var filteredUsers = [User]()
    
    
    // MARK: - View Setup
    
    override func viewDidLoad() {
        self.setUpSearchController()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Invite", style: .Plain,
                                                                       target: self, action: #selector(FriendsViewController.invite(_:)))
        super.viewDidLoad()
    }
    
    
    @objc private func invite(sender: UIBarButtonItem) {
        self.controller!.performSegueWithIdentifier("toInvite", sender: self)
    }
}

extension FriendsViewController: UISearchResultsUpdating {
    
    private func setUpSearchController() {
        let userListController = self.storyboard?.instantiateViewControllerWithIdentifier("UserListViewController") as! UserListViewController
        
//        userListController.tintColor = self.tintColor!
        userListController.controller = self
        
        self.searchController = UISearchController(searchResultsController: userListController)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.tintColor = self.tintColor
        self.searchController.searchBar.barTintColor = whiteColor
        self.searchController.searchBar.searchBarStyle = .Prominent
        self.searchController.searchBar.placeholder = "Search users"
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        
        let textField = searchController.searchBar.valueForKey("searchField") as! UITextField
        textField.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
    }
    
    
    // MARK: UISearchResultsUpdating Methods
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let userListController = searchController.searchResultsController as! UserListViewController
        
        filterContentForSearchText(searchController.searchBar.text!)
        
        userListController.userSource = { return self.filteredUsers }
        userListController.refresh()
    }
    
    private func filterContentForSearchText(searchText: String) {
        filteredUsers = userSearchSource.filter({( user : User) -> Bool in
            return (user.username.lowercaseString.containsString(searchText.lowercaseString) || user.fullname.lowercaseString.containsString(searchText.lowercaseString))
        })
        
        api.searchUsers(searchText, callback: addToSearch)
    }
    
    private func addToSearch(user: User) {
        userSearchSource.insert(user)
    }
    
    
    // MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if searchController.active {
            let userListController = searchController.searchResultsController as! UserListViewController
            let targetController = segue.destinationViewController as! ProfileViewController
            if let row = userListController.tableView.indexPathForSelectedRow?.row {
                targetController.tintColor = tintColor
                targetController.navigationItem.title = filteredUsers[row].username
                targetController.userInstance = filteredUsers[row]
            }
        } else {
            super.prepareForSegue(segue, sender: sender)
        }
    }
}