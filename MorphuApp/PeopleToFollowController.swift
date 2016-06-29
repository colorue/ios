//
//  PeopleToFollowController.swift
//  Colorue
//
//  Created by Dylan Wight on 6/29/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class PeopleToFollowController: UserListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true)
        print("PeopleToFollowController")
        
        self.userSource =  api.getSuggustedUsers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print(userSource.count)
        self.tableView.reloadData()
    }
}