//
//  InboxDrawingCell.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var cover: UIView!
}