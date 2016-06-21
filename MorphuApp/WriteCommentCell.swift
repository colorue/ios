//
//  WriteCommentCell.swift
//  Morphu
//
//  Created by Dylan Wight on 5/24/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class WriteCommentCell: UITableViewCell {
    var delagate: WriteCommentCellDelagate?
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var commentText: UITextField!
    
    @IBAction func addComment(sender: UIButton) {
        if let text = commentText.text {
            delagate?.addComment(text)
        }
    }
}