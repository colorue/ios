//
//  InboxDrawingCell.swift
//  Colorue
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    static let commentFont = UIFont(resource: R.font.openSans, size: 14.0)!
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            
            username?.text = comment.user.username
            profileImage?.image = comment.user.profileImage
            timeStamp?.text = comment.getTimeSinceSent()
            commentText?.text = comment.text
        }
    }
    
    var buttonTag: Int = 0 {
        didSet {
            userButton?.tag = buttonTag
        }
    }
    
    @IBOutlet weak var profileImage: UIImageView?
    @IBOutlet weak var username: UILabel?
    @IBOutlet weak var timeStamp: UILabel?
    @IBOutlet weak var commentText: UILabel? {
        didSet {
            commentText?.font = CommentCell.commentFont
        }
    }
    @IBOutlet weak var userButton: UIButton?
}
