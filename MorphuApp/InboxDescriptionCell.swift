//
//  InboxTableViewCell.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class InboxDescriptionCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var group: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var actionIcon: UIImageView!
    @IBOutlet weak var timeCreated: UILabel!
}