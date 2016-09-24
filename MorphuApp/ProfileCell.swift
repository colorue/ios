//
//  ProfileCell.swift
//  Colorue
//
//  Created by Dylan Wight on 6/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

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
            fullName?.text = user?.fullname
            profileImage?.image = user?.profileImage
            drawingsCount?.text = String(user?.getDrawings().count ?? 0)
            followersCount?.text = String(user?.getFollowers().count ?? 0)
            followingCount?.text = String(user?.getFollowing().count ?? 0)
            
            if user?.userId == API.sharedInstance.getActiveUser().userId {
                followButton?.setImage(nil, for: UIControlState())
                followButton?.isEnabled = false
            } else {
                followButton?.isSelected = API.sharedInstance.getActiveUser().isFollowing(user)
            }
        }
    }
    
    var color: UIColor = redColor {
        didSet {
            followButton?.tintColor = color
            if color == redColor {
                followButton?.setImage(UIImage(named: "Followed Red"), for: .selected)
            } else if color == orangeColor {
                followButton?.setImage(UIImage(named: "Followed Orange"), for: .selected)
            } else if color == blueColor {
                followButton?.setImage(UIImage(named: "Followed Blue"), for: .selected)
            } else {
                followButton?.setImage(UIImage(named: "Followed Purple"), for: .selected)
            }
        }
    }
}
