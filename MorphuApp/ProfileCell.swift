//
//  ProfileCell.swift
//  Colorue
//
//  Created by Dylan Wight on 6/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Kingfisher

protocol ProfileCellDelagate {
    func followAction(_ sender: UIButton) -> ()
}

class ProfileCell: UITableViewCell {

    @IBOutlet weak var fullName: UILabel?
    @IBOutlet weak var profileImage: UIImageView?
    @IBOutlet weak var drawingsCount: UILabel?
    @IBOutlet weak var followersCount: UILabel?
    @IBOutlet weak var followingCount: UILabel?
    
    @IBOutlet weak var followersButton: UIButton?
    @IBOutlet weak var followingButton: UIButton?
    @IBOutlet weak var followButton: UIButton?
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            
            fullName?.text = user.fullname
            profileImage?.kf.setImage(with: URL(string: user.profileURL))
            drawingsCount?.text = String(user.getDrawings().count)
            followersCount?.text = String(user.getFollowers().count)
            followingCount?.text = String(user.getFollowing().count)
            
            if user.userId == API.sharedInstance.getActiveUser().userId {
                followButton?.setImage(nil, for: UIControlState())
                followButton?.isEnabled = false
            } else {
                followButton?.isSelected = API.sharedInstance.getActiveUser().isFollowing(user)
            }
        }
    }
    
    var color: UIColor = Theme.red {
        didSet {
            followButton?.tintColor = color
            if color == Theme.red {
                followButton?.setImage(UIImage(named: "Followed Red"), for: .selected)
            } else if color == Theme.orange {
                followButton?.setImage(UIImage(named: "Followed Orange"), for: .selected)
            } else if color == Theme.blue {
                followButton?.setImage(UIImage(named: "Followed Blue"), for: .selected)
            } else {
                followButton?.setImage(UIImage(named: "Followed Purple"), for: .selected)
            }
        }
    }
}
