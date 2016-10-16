//
//  HashTagCell.swift
//  Colorue
//
//  Created by Dylan Wight on 10/16/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
import ActiveLabel

class HashTagsCell: UITableViewCell {
    
    @IBOutlet weak var hashTagsLabel: ActiveLabel? {
        didSet {
            hashTagsLabel?.font = R.font.openSans(size: 14.0)
        }
    }
    
    var hashTags: [HashTag]? {
        didSet {
            guard let hashTags = hashTags else { return }
            let text = hashTags.flatMap({ $0.displayText })
            hashTagsLabel?.text = text.joined(separator: ", ")
        }
    }
    
    func common_init() {
        backgroundColor = Theme.background
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        common_init()
    }
}
