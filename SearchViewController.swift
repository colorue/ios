


import UIKit

class SearchViewController: UITableViewController, UISearchResultsUpdating, UserCellDelagate {

    // MARK: - Properties
    let api = API.sharedInstance
    let searchController = UISearchController(searchResultsController: nil)
    var userSource = API.sharedInstance.getUsers
    var filteredUsers = [User]()
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        searchController.searchResultsUpdater = self
        
        searchController.searchBar.tintColor = orangeColor
        searchController.searchBar.barTintColor = whiteColor
        
        let textField = searchController.searchBar.valueForKey("searchField") as! UITextField
        textField.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        
        searchController.searchBar.searchBarStyle = .Prominent
        searchController.searchBar.placeholder = "Search users"

        filteredUsers = userSource()
        
        self.searchController.searchResultsUpdater = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.navigationItem.titleView = searchController.searchBar
        
        self.definesPresentationContext = true
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if searchController.active && searchController.searchBar.text != "" {
//            return filteredUsers.count
//        }
        return filteredUsers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as! UserCell
        
        let user = userSource()[indexPath.row]
        cell.username.text = user.username
        cell.profileImage.image = user.profileImage
        cell.fullName.text = user.fullname
        cell.delagate = self
        cell.user = user
        
        if user.userId == api.getActiveUser().userId {
            cell.followButton.hidden = true
        } else {
            cell.followButton.selected = api.getActiveUser().isFollowing(user)
        }
        
        return cell
    }
    
    private func filterContentForSearchText(searchText: String) {
        if searchText == "" {
            filteredUsers = userSource()
        } else {
            filteredUsers = userSource().filter({( user : User) -> Bool in
                return (user.username.lowercaseString.containsString(searchText.lowercaseString) || user.fullname.lowercaseString.containsString(searchText.lowercaseString))
            })
        }
        tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    // MARK: UserCellDelagate Methods
    
    func followAction(userCell: UserCell) {
        userCell.followButton.selected = true
        
        api.getActiveUser().follow(userCell.user!)
        api.follow(userCell.user!)
    }
    
    func unfollowAction(userCell: UserCell) {
        if let user = userCell.user {
            let actionSelector = UIAlertController(title: "Unfollow \(user.username)?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSelector.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            actionSelector.addAction(UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.Destructive,
                handler: {(alert: UIAlertAction!) in self.unfollow(userCell)}))
            
            self.presentViewController(actionSelector, animated: true, completion: nil)
        }
    }
    
    private func unfollow(userCell: UserCell) {
        userCell.followButton.selected = false
        api.getActiveUser().unfollow(userCell.user!)
        api.unfollow(userCell.user!)
    }
    
    
    // MARK: - Segues
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showUser", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showUser" {
            let targetController = segue.destinationViewController as! ProfileViewController
            if let row = tableView.indexPathForSelectedRow?.row {
                targetController.navigationItem.title = userSource()[row].username
                targetController.userInstance = userSource()[row]
            }
        }
    }
}