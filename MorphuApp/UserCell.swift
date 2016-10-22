//
//  UserTableViewCell.swift
//  Colorue
//
//  Created by Dylan Wight on 5/17/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Kingfisher

protocol UserCellDelegate {
    func followAction(_ userCell: UserCell)
    func unfollowAction(_ userCell: UserCell)
}

class UserCell: UITableViewCell {
    var delegate: UserCellDelegate?
    var user: User? {
        didSet {
            guard let user = user else { return }
            
            username?.text = user.username
            fullName?.text = user.fullname
            profileImage?.kf.setImage(with: URL(string: user.profileURL))
            
            if user.userId == API.sharedInstance.getActiveUser().userId {
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
            delegate?.followAction(self)
        } else {
            delegate?.unfollowAction(self)
        }
    }
}
