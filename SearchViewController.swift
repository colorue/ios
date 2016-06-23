


import UIKit

class SearchViewController: DrawingListViewController, UISearchResultsUpdating {

    // MARK: - Properties
    
    var searchController = UISearchController(searchResultsController: nil)
    var userSource = API.sharedInstance.getUsers
    var filteredUsers = [User]()
    
    
    // MARK: - View Setup
    
    override func viewDidLoad() {
        self.tintColor = orangeColor
        self.setUpSearchController()
        api.loadExplore()
        self.drawingSource = API.sharedInstance.getExplore
        
        loadMoreDrawings = api.loadExplore

        bottomRefreshControl.addTarget(self, action: #selector(SearchViewController.refresh), forControlEvents: .ValueChanged)

        super.viewDidLoad()
    }
    
    private func setUpSearchController() {
        let userListController = self.storyboard?.instantiateViewControllerWithIdentifier("UserListViewController") as! UserListViewController
        
        userListController.tintColor = self.tintColor!
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
        filteredUsers = userSource().filter({( user : User) -> Bool in
            return (user.username.lowercaseString.containsString(searchText.lowercaseString) || user.fullname.lowercaseString.containsString(searchText.lowercaseString))
        })
    }
    
    
    // MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if searchController.active {
            print("searchController.active")
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