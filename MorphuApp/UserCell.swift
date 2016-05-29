//
//  UserTableViewCell.swift
//  Morphu
//
//  Created by Dylan Wight on 5/17/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    var delagate: UserCellDelagate?
    var user: User?
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    @IBAction func followAction(sender: UIButton) {
        
        if !(sender.selected) {
            delagate?.followAction(self)
        } else {
            delagate?.unfollowAction(self)
        }
    }
}