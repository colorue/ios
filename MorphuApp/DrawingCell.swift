//
//  InboxDrawingCell.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class DrawingCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var drawingImage: UIImageView!
    @IBOutlet weak var timeCreated: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    
    
    func stProgress(progress: Float) {
        progressBar.setProgress(1.0 - progress, animated: true)
    }
    
    func imageLoaded(image: UIImage) {
        self.drawingImage.image = image
    }
}