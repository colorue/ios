//
//  InboxDrawingCell.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class DrawingCell: UITableViewCell {
    
    var delagate: DrawingCellDelagate?
    var drawing: Drawing?
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var drawingImage: UIImageView!
    @IBOutlet weak var timeCreated: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCount: UIButton!
    @IBOutlet weak var likes: UILabel!
    
    @IBAction func upload(sender: UIButton) {
        delagate?.upload(self)
    }
    
    @IBAction func like(sender: UIButton) {
        if !(drawing?.liked())! {
            sender.selected = true
            delagate?.like(self)
        } else {
            sender.selected = false
            delagate?.unlike(self)
        }
    }
    
    @IBAction func viewLikes(sender: UIButton) {
        delagate?.viewLikes(self)
    }
}