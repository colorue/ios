//
//  InboxDrawingCell.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

protocol DrawingCellDelagate {
    func presentDrawingActions(drawing: Drawing)
    func likeButtonPressed(drawing: Drawing)
}

class DrawingCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView?
    @IBOutlet weak var creator: UILabel?
    @IBOutlet weak var drawingImage: UIImageView?
    @IBOutlet weak var timeCreated: UILabel?
    @IBOutlet weak var likes: UILabel?
    @IBOutlet weak var commentCount: UILabel?
    
    @IBOutlet weak var userButton: UIButton?
    @IBOutlet weak var uploadButton: UIButton?
    @IBOutlet weak var likeButton: UIButton?
    @IBOutlet weak var likesButton: UIButton?
    @IBOutlet weak var commentsButton: UIButton?
    
    @IBOutlet weak var drawingOfTheDayLabel: UILabel?
    
    
    var cellTag: Int? {
        didSet {
            userButton?.tag = cellTag ?? 0
            uploadButton?.tag = cellTag ?? 0
            likeButton?.tag = cellTag ?? 0
            likesButton?.tag = cellTag ?? 0
            commentsButton?.tag = cellTag ?? 0
        }
    }
    
    var color: UIColor? {
        didSet {
            uploadButton?.tintColor = color
            likeButton?.tintColor = color
            likes?.textColor = color
            commentCount?.textColor = color
        }
    }
    
    var delagate: DrawingCellDelagate? {
        didSet {
            // TODO: move to init
            uploadButton?.addTarget(self, action: #selector(DrawingCell.presentDrawingActions(_:)), forControlEvents: .TouchUpInside)
            likeButton?.addTarget(self, action: #selector(DrawingCell.likeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    var drawing: Drawing? {
        didSet {
            
            if let url = drawing?.url {
                drawingImage?.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: [.Transition(.Fade(0.2))],
                                                 completionHandler: { (image, error, cacheType, imageURL) -> () in
                    self.drawing?.setImage(image)
                })
            }
            
            profileImage?.image = drawing?.getArtist().profileImage
            creator?.text = drawing?.getArtist().username
            timeCreated?.text = drawing?.getTimeSinceSent()
            likeButton?.selected = drawing?.liked(API.sharedInstance.getActiveUser()) ?? false
            
            if drawing?.getComments().count == 1 {
                commentCount?.text = "1 comment"
            } else {
                commentCount?.text = String(drawing?.getComments().count ?? 0) + " comments"
            }
            setLikes()
        }
    }
    
    @objc private func presentDrawingActions(sender: UIButton) {
        guard let drawing = drawing else { return }
        delagate?.presentDrawingActions(drawing)
    }
    
    @objc private func likeButtonPressed(sender: UIButton) {
        guard let drawing = drawing else { return }
        
        sender.selected = !sender.selected
        delagate?.likeButtonPressed(drawing)
        setLikes()
    }
        
    private func setLikes() {
        let likeCount = drawing?.getLikes().count ?? 0
        if likeCount == 0 {
            likes?.text = ""
            likesButton?.enabled = false
        } else if likeCount == 1 {
            likesButton?.enabled = true
            likes?.text = "1 like"
        } else {
            likesButton?.enabled = true
            likes?.text = String(likeCount) + " likes"
        }
    }
}