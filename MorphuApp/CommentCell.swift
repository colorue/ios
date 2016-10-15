//
//  InboxDrawingCell.swift
//  Colorue
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import ActiveLabel
import Kingfisher

class CommentCell: UITableViewCell {
    
    static let commentFont = UIFont(resource: R.font.openSans, size: 14.0)!
    
    var delegate: ActiveLabelDelegate? {
        didSet {
            commentText?.delegate = delegate
        }
    }
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
        
            username?.text = comment.user.username
            timeStamp?.text = comment.timeStamp.timeSince
            commentText?.text = comment.text
            
            profileImage?.kf.setImage(with: URL(string: comment.user.profileURL), placeholder: nil, options: [.transition(.fade(0.2))], completionHandler: nil)
        }
    }
    
    var buttonTag: Int = 0 {
        didSet {
            userButton?.tag = buttonTag
        }
    }
    
    var tint: UIColor? {
        didSet {
            guard let tint = tint  else { return }
            commentText?.hashtagColor = tint
            commentText?.mentionColor = tint
        }
    }
    
    @IBOutlet weak var profileImage: UIImageView?
    @IBOutlet weak var username: UILabel?
    @IBOutlet weak var timeStamp: UILabel?
    
    @IBOutlet weak var commentText: ActiveLabel? {
        didSet {
            commentText?.font = CommentCell.commentFont
            commentText?.enabledTypes = [.mention, .hashtag]
        }
    }
    @IBOutlet weak var userButton: UIButton?
}
