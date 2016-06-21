


import UIKit

class SearchViewController: UITableViewController, UISearchResultsUpdating, UserCellDelagate, UISearchControllerDelegate, UISearchBarDelegate, APIDelagate {

    // MARK: - Properties
    let api = API.sharedInstance
    let searchController = UISearchController(searchResultsController: nil)
    var userSource = API.sharedInstance.getUsers
    var filteredUsers = [User]()
    
    let drawingSource = API.sharedInstance.getExplore

    var searchActive = true
    var exploreContentOffset = CGPoint.zero
    
    let bottomRefreshControl = UIRefreshControl()
    
    var tintColor = orangeColor

    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 586.0
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = backgroundColor
        
        searchController.searchResultsUpdater = self
        
        searchController.searchBar.tintColor = orangeColor
        searchController.searchBar.barTintColor = whiteColor
        
        let textField = searchController.searchBar.valueForKey("searchField") as! UITextField
        textField.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        
        searchController.searchBar.searchBarStyle = .Prominent
        searchController.searchBar.placeholder = "Search users"
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        filteredUsers = userSource()
        
        self.searchController.searchResultsUpdater = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.navigationItem.titleView = searchController.searchBar
        
        self.definesPresentationContext = true
        
        api.loadExplore()
        
        bottomRefreshControl.triggerVerticalOffset = 50.0
        bottomRefreshControl.addTarget(self, action: #selector(SearchViewController.refresh), forControlEvents: .ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        api.delagate = self
        
        self.tableView.reloadData()
        self.tableView.bottomRefreshControl = bottomRefreshControl // Needs to be in viewDidApear
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredUsers.count
        } else {
            return drawingSource().count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if searchActive {
            return tableView.dequeueReusableCellWithIdentifier("UserCell")! as! UserCell
        } else {
            return self.tableView.dequeueReusableCellWithIdentifier("DrawingCell", forIndexPath: indexPath) as! DrawingCell
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                            forRowAtIndexPath indexPath: NSIndexPath) {
        if searchActive {
            let userCell = cell as! UserCell
            let user = filteredUsers[indexPath.row]
            userCell.username.text = user.username
            userCell.profileImage.image = user.profileImage
            userCell.fullName.text = user.fullname
            userCell.delagate = self
            userCell.user = user
            
            if user.userId == api.getActiveUser().userId {
                userCell.followButton.hidden = true
            } else {
                userCell.followButton.selected = api.getActiveUser().isFollowing(user)
            }
        } else {
            let drawing = drawingSource()[indexPath.row]
            let drawingCell = cell as! DrawingCell
            
            drawingCell.drawingImage.alpha = 0.0
            drawingCell.progressBar.hidden = true
            
            api.downloadImage(drawing.getDrawingId(),
                              progressCallback: { (progress: Float) -> () in
                                drawingCell.progressBar.setProgress(progress, animated: true)
                },
                              finishedCallback: { (drawingImage: UIImage) -> () in
                                drawingCell.progressBar.hidden = true
                                drawingCell.drawingImage.image = drawingImage
                                drawing.setImage(drawingImage)
                                
                                UIView.animateWithDuration(0.3,delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                                    drawingCell.drawingImage.alpha = 1.0
                                    }, completion: nil)
            })
            
            drawingCell.profileImage.image = drawing.getArtist().profileImage
            drawingCell.creator.text = drawing.getArtist().username
            drawingCell.timeCreated.text = drawing.getTimeSinceSent()
            drawingCell.likeButton.selected = drawing.liked(api.getActiveUser())
            
            drawingCell.userButton.tag = indexPath.row
            drawingCell.uploadButton.tag = indexPath.row
            drawingCell.likeButton.tag = indexPath.row
            drawingCell.likesButton.tag = indexPath.row
            drawingCell.commentsButton.tag = indexPath.row
            
            drawingCell.uploadButton.addTarget(self, action: #selector(WallViewController.upload(_:)), forControlEvents: .TouchUpInside)
            drawingCell.likeButton.addTarget(self, action: #selector(WallViewController.likeButtonPressed(_:)), forControlEvents: .TouchUpInside)
            
            let likes = drawing.getLikes().count
            if likes == 0 {
                drawingCell.likes.text = ""
                drawingCell.likesButton.enabled = false
            } else if likes == 1 {
                drawingCell.likesButton.enabled = true
                drawingCell.likes.text = "1 like"
            } else {
                drawingCell.likesButton.enabled = true
                drawingCell.likes.text = String(likes) + " likes"
            }
            
            if drawing.getComments().count == 1 {
                drawingCell.commentCount.text = "1 comment"
            } else {
                drawingCell.commentCount.text = String(drawing.getComments().count) + " comments"
            }
            
            if (indexPath.row + 1 >= drawingSource().count) {
                api.loadExplore()
            }
        }
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
    
    
    
    func setLikes(drawing: Drawing, indexPath: NSIndexPath) {
        
        let drawingCell = tableView.cellForRowAtIndexPath(indexPath) as! DrawingCell
        let likes = drawing.getLikes().count
        if likes == 0 {
            drawingCell.likes.text = ""
            drawingCell.likesButton.enabled = false
        } else if likes == 1 {
            drawingCell.likesButton.enabled = true
            drawingCell.likes.text = "1 like"
        } else {
            drawingCell.likesButton.enabled = true
            drawingCell.likes.text = String(likes) + " likes"
        }
    }
    
    func likeButtonPressed(sender: UIButton) {
        let drawing = drawingSource()[sender.tag]
        
        if !(drawing.liked(api.getActiveUser())) {
            sender.selected = true
            api.like(drawing)
        } else {
            sender.selected = false
            api.unlike(drawing)
        }
        self.setLikes(drawing, indexPath: NSIndexPath(forRow: sender.tag, inSection: 1))
    }
    
    // MARK: SearchControllerDelagate Methods
    
    func  presentSearchController(searchController: UISearchController) {
//        self.tableView.setContentOffset(CGPointZero, animated: true)
//        self.exploreContentOffset = self.tableView.contentOffset

        self.searchActive = true
        
//        self.tableView.setContentOffset(CGPoint.zero, animated: false)

//        self.tableView.reloadData()
    }
    
    // MARK: UISearchBarDelagate Methods
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        self.searchActive = false
//        self.tableView.setContentOffset(self.exploreContentOffset, animated: false)
    }
    
    
    // MARK: APIDelagate Methods
    
    func refresh() {
        self.tableView.reloadData()
        self.bottomRefreshControl.endRefreshing()
    }
    
    // MARK: - Segues
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchActive {
            self.performSegueWithIdentifier("showUser", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showUser" {
            let targetController = segue.destinationViewController as! ProfileViewController
            if let row = tableView.indexPathForSelectedRow?.row {
                targetController.tintColor = tintColor
                targetController.navigationItem.title = userSource()[row].username
                targetController.userInstance = userSource()[row]
            }
        }
    }
}