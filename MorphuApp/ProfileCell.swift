//
//  ProfileCell.swift
//  Canvi
//
//  Created by Dylan Wight on 6/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

@objc protocol ProfileCellDelagate {
    @objc func followAction(sender: UIButton) -> ()
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
                followButton?.setImage(nil, forState: .Normal)
                followButton?.enabled = false
            } else {
                followButton?.selected = API.sharedInstance.getActiveUser().isFollowing(user)
            }
        }
    }
    
    var delagate: ProfileCellDelagate? {
        didSet {
            followButton?.addTarget(self, action: #selector(delagate?.followAction(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    var color: UIColor = redColor {
        didSet {
            if color == redColor {
                followButton?.setImage(UIImage(named: "Followed Red"), forState: .Selected)
            } else if tintColor == orangeColor {
                followButton?.setImage(UIImage(named: "Followed Orange"), forState: .Selected)
            } else if tintColor == blueColor {
                followButton?.setImage(UIImage(named: "Followed Blue"), forState: .Selected)
            } else {
                followButton?.setImage(UIImage(named: "Followed Purple"), forState: .Selected)
            }
        }
    }
}
