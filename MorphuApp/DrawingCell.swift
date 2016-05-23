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
    
    @IBAction func like(sender: UIButton) {
        if let drawing = self.drawing {
            delagate?.like(drawing)
        }
    }
}