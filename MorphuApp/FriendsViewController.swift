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
    var userSearchSource = API.sharedInstance.getActiveUser().getFollowers().intersection(API.sharedInstance.getActiveUser().getFollowing())
    var filteredUsers = [User]()
    
    
    // MARK: - View Setup
    
    override func viewDidLoad() {
        
        self.setUpSearchController()
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Invite ", style: .plain,
                                                                       target: self, action: #selector(FriendsViewController.invite(_:)))
        super.viewDidLoad()
    }
    
    
    @objc fileprivate func invite(_ sender: UIBarButtonItem) {
        self.controller!.performSegue(withIdentifier: "toInvite", sender: self)
    }
}

extension FriendsViewController: UISearchResultsUpdating {
    
    fileprivate func setUpSearchController() {
        guard let userListController = R.storyboard.users.users() else { return }
        
//        userListController.tintColor = self.tintColor!
        userListController.controller = self
        
        self.searchController = UISearchController(searchResultsController: userListController)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.tintColor = self.tintColor
        self.searchController.searchBar.barTintColor = whiteColor
        self.searchController.searchBar.searchBarStyle = .prominent
        self.searchController.searchBar.placeholder = "Search users"
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        
        let textField = searchController.searchBar.value(forKey: "searchField") as! UITextField
        textField.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        
    }
    
    
    // MARK: UISearchResultsUpdating Methods
    
    func updateSearchResults(for searchController: UISearchController) {
        let userListController = searchController.searchResultsController as! UserListViewController
        
        filterContentForSearchText(searchController.searchBar.text!)
        
        userListController.userSource = { return self.filteredUsers }
        userListController.refresh()
    }
    
    fileprivate func filterContentForSearchText(_ searchText: String) {
        filteredUsers = userSearchSource.filter({( user : User) -> Bool in
            return (user.username.lowercased().contains(searchText.lowercased()) || user.fullname.lowercased().contains(searchText.lowercased()))
        })
        
        api.searchUsers(searchText, callback: addToSearch)
    }
    
    fileprivate func addToSearch(_ user: User) {
        userSearchSource.insert(user)
    }
    
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if searchController.isActive {
            let userListController = searchController.searchResultsController as! UserListViewController
            if let targetController = segue.destination as? ProfileViewController {
                if let row = (userListController.tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                    targetController.tintColor = tintColor
                    targetController.navigationItem.title = filteredUsers[row].username
                    targetController.userInstance = filteredUsers[row]
                }
            }
        }
    }
}
