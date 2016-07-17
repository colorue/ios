//
//  FriendsViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

class FriendsViewController: UserListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Invite", style: .Plain,
                                                                 target: self, action: #selector(FriendsViewController.invite(_:)))
    }
    
    @objc private func invite(sender: UIBarButtonItem) {
        self.controller!.performSegueWithIdentifier("toInvite", sender: self)
    }
}