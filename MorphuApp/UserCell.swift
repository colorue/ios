//
//  UserTableViewCell.swift
//  Morphu
//
//  Created by Dylan Wight on 5/17/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

protocol UserCellDelagate {
    func followAction(userCell: UserCell)
    func unfollowAction(userCell: UserCell)
}

class UserCell: UITableViewCell {
    var delagate: UserCellDelagate?
    var user: User? {
        didSet {
            username?.text = user?.username
            fullName?.text = user?.fullname
            profileImage?.image = user?.profileImage
            
            if user?.userId == API.sharedInstance.getActiveUser().userId {
                followButton?.hidden = true
            } else {
                followButton?.selected = API.sharedInstance.getActiveUser().isFollowing(user)
                followButton?.hidden = false
            }
        }
    }
    
    var color: UIColor = redColor {
        didSet {
            followButton?.tintColor = color
        }
    }
    
    @IBOutlet weak var followButton: UIButton?
    @IBOutlet weak var profileImage: UIImageView?
    @IBOutlet weak var username: UILabel?
    @IBOutlet weak var fullName: UILabel?

    @IBAction func followAction(sender: UIButton) {

        if !(sender.selected) {
            delagate?.followAction(self)
        } else {
            delagate?.unfollowAction(self)
        }
    }
}