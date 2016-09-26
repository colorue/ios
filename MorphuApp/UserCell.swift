//
//  UserTableViewCell.swift
//  Colorue
//
//  Created by Dylan Wight on 5/17/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

protocol UserCellDelagate {
    func followAction(_ userCell: UserCell)
    func unfollowAction(_ userCell: UserCell)
}

class UserCell: UITableViewCell {
    var delagate: UserCellDelagate?
    var user: User? {
        didSet {
            username?.text = user?.username
            fullName?.text = user?.fullname
            profileImage?.image = user?.profileImage
            
            if user?.userId == API.sharedInstance.getActiveUser().userId {
                followButton?.isHidden = true
            } else {
                followButton?.isSelected = API.sharedInstance.getActiveUser().isFollowing(user)
                followButton?.isHidden = false
            }
        }
    }
    
    var color: UIColor? {
        didSet {
            followButton?.tintColor = color
        }
    }
    
    @IBOutlet weak var followButton: UIButton?
    @IBOutlet weak var profileImage: UIImageView?
    @IBOutlet weak var username: UILabel?
    @IBOutlet weak var fullName: UILabel?

    @IBAction func followAction(_ sender: UIButton) {

        if !(sender.isSelected) {
            delagate?.followAction(self)
        } else {
            delagate?.unfollowAction(self)
        }
    }
}
