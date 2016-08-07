//
//  PromptTableViewCell.swift
//  Colorue
//
//  Created by Dylan Wight on 8/6/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class PromptCell: UITableViewCell {
    var prompt: Prompt? {
        didSet {
            guard let prompt = prompt else { return }
            
            username?.text = prompt.user.username
            profileImage?.image = prompt.user.profileImage
            timeStamp?.text = prompt.getTimeSinceSent()
            commentText?.text = prompt.text
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
    @IBOutlet weak var commentText: UILabel?
    @IBOutlet weak var userButton: UIButton?
}