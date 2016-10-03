//
//  UserViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 6/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Firebase

class ProfileViewController: DrawingListViewController {
    
    var username: String? {
        didSet {
            guard let username = username else { return }
            API.sharedInstance.searchUsers(username) { [weak self] user in
                self?.userInstance = user
            }
        }
    }
    
    var userInstance: User? {
        didSet {
            guard let userInstance = userInstance else { return }
            UserService().getFull(user: userInstance)
            self.drawingSource = userInstance.getDrawings
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let prefs = UserDefaults.standard
        if (!prefs.bool(forKey: "firstProfileView")) && userInstance?.userId == API.sharedInstance.getActiveUser().userId {
            prefs.setValue(true, forKey: "firstProfileView")
            
            let firstProfileView = UIAlertController(title: "Set your profile drawing", message: "Press ↥ to upload, download, edit, or set a drawing as your profile picture" , preferredStyle: UIAlertControllerStyle.alert)
            firstProfileView.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(firstProfileView, animated: true, completion: nil)
        }
    }
}


// MARK: - Table view data source

extension ProfileViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return userInstance?.getDrawings().count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            return self.tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        } else {
            return self.tableView.dequeueReusableCell(withIdentifier: "DrawingCell", for: indexPath) as! DrawingCell
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == 0 {
            let profileCell = cell as! ProfileCell
            profileCell.user = userInstance
            profileCell.color = tintColor ?? redColor
            profileCell.followButton?.addTarget(self, action: #selector(ProfileViewController.followAction(_:)), for: .touchUpInside)
        } else {
            super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }
}

extension ProfileViewController: ProfileCellDelagate {
    func followAction(_ sender: UIButton) {
        guard let userInstance = userInstance else { return }
        
        if !sender.isSelected {
            sender.isSelected = true
            api.getActiveUser().follow(userInstance)
            api.follow(userInstance)
            FIRAnalytics.logEvent(withName: "followedUser", parameters: [:])
        } else {
            let actionSelector = UIAlertController(title: "Unfollow \(userInstance.username)?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            actionSelector.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            actionSelector.addAction(UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.destructive,
                handler: {(alert: UIAlertAction!) in self.unfollow(sender)}))
            
            self.present(actionSelector, animated: true, completion: nil)
        }
    }
    
    fileprivate func unfollow(_ sender: UIButton) {
        guard let userInstance = userInstance else { return }

        sender.isSelected = false
        api.getActiveUser().unfollow(userInstance)
        api.unfollow(userInstance)
        FIRAnalytics.logEvent(withName: "unfollowedUser", parameters: [:])
    }
}


// MARK: Segues

extension ProfileViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let userInstance = userInstance else { return }

        
        if segue.identifier == "showFollowers" {
            let targetController = segue.destination as! UserListViewController
            targetController.tintColor = self.tintColor!
            targetController.navigationItem.title = "Followers"
            targetController.userSource = { return Array(userInstance.getFollowers()) }
        } else if segue.identifier == "showFollowing" {
            let targetController = segue.destination as! UserListViewController
            targetController.tintColor = self.tintColor!
            targetController.navigationItem.title = "Following"
            targetController.userSource = { return Array(userInstance.getFollowing()) }
        } else if let targetController = segue.destination as? UserListViewController {
            let drawing = getClickedDrawing(sender! as AnyObject)
            targetController.navigationItem.title = "Likes"
            targetController.tintColor = self.tintColor!
            targetController.userSource = { return drawing.likes }
        } else if let targetController = segue.destination as? CommentViewController {
            let drawing = getClickedDrawing(sender! as AnyObject)
            targetController.tintColor = self.tintColor!
            targetController.drawingInstance = drawing
        } else if let targetController = segue.destination as? ProfileViewController {
            let drawing = getClickedDrawing(sender! as AnyObject)
            targetController.navigationItem.title = drawing.user.username
            targetController.tintColor = self.tintColor!
            targetController.userInstance = drawing.user
        }
    }
    
    func addLogoutButton() {
        let chevron = UIImage(named: "Logout")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: chevron, style: .plain, target: self,                                                                action: #selector(ProfileViewController.logoutPopup(_:)))
    }
    
    func logoutPopup(_ sender: UIBarButtonItem) {
        
        let logoutConfirm = UIAlertController(title: "Log out?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        logoutConfirm.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { (action: UIAlertAction!) in
            FIRAnalytics.logEvent(withName: "loggedOut", parameters: [:])
            self.api.clearData()
            AuthAPI.sharedInstance.logout()
            self.performSegue(withIdentifier: "logout", sender: self)
        }))
        
        logoutConfirm.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
        self.present(logoutConfirm, animated: true, completion: nil)
    }
}
