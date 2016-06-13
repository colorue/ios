


import UIKit

class SearchViewController: UITableViewController, UISearchResultsUpdating {
    
    // MARK: - Properties
    var candies = [String]()
    var filteredCandies = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        self.navigationController?.navigationBarHidden = true
        
        searchController.searchResultsUpdater = self
        
        searchController.searchBar.tintColor = orangeColor
        searchController.searchBar.barTintColor = whiteColor
        
        let textField = searchController.searchBar.valueForKey("searchField") as! UITextField
        textField.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        
        searchController.searchBar.searchBarStyle = .Prominent
        
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
        
        candies = ["a", "b", "dog", "cat", "horse", "goat"]
        filteredCandies = candies
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredCandies.count
        }
        return filteredCandies.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! UserCell
        cell.username.text = filteredCandies[indexPath.row]
        return cell
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredCandies = candies.filter({( candy : String) -> Bool in
            return candy.lowercaseString.containsString(searchText.lowercaseString)
        })
        tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    // MARK: - Segues
}