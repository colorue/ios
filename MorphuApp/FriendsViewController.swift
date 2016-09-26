//
//  FriendsViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

class FriendsViewController: UserListViewController {
    
    // MARK: - View Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Invite ", style: .plain, target: self,
                            action: #selector(FriendsViewController.invite(_:)))
    }
    
    
    @objc fileprivate func invite(_ sender: UIBarButtonItem) {
        self.controller!.performSegue(withIdentifier: "toInvite", sender: self)
    }
}
