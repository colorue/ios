//
//  InboxDrawingCell.swift
//  Colorue
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

protocol DrawingCellDelagate {
    func presentDrawingActions(_ drawing: Drawing)
    func likeButtonPressed(_ drawing: Drawing)
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
            uploadButton?.addTarget(self, action: #selector(DrawingCell.presentDrawingActions(_:)), for: .touchUpInside)
            likeButton?.addTarget(self, action: #selector(DrawingCell.likeButtonPressed(_:)), for: .touchUpInside)
        }
    }
    
    var drawing: Drawing? {
        didSet {
            
            if let url = drawing?.url {
                drawingImage?.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.2))],
                                                 completionHandler: { (image, error, cacheType, imageURL) -> () in
                    self.drawing?.setImage(image)
                })
            }
            
            profileImage?.image = drawing?.getArtist().profileImage
            creator?.text = drawing?.getArtist().username
            timeCreated?.text = drawing?.getTimeSinceSent()
            likeButton?.isSelected = drawing?.liked(API.sharedInstance.getActiveUser()) ?? false
            
            if drawing?.getComments().count == 1 {
                commentCount?.text = "1 comment"
            } else {
                commentCount?.text = String(drawing?.getComments().count ?? 0) + " comments"
            }
            setLikes()
        }
    }
    
    @objc fileprivate func presentDrawingActions(_ sender: UIButton) {
        guard let drawing = drawing else { return }
        delagate?.presentDrawingActions(drawing)
    }
    
    @objc fileprivate func likeButtonPressed(_ sender: UIButton) {
        guard let drawing = drawing else { return }
        
        sender.isSelected = !sender.isSelected
        delagate?.likeButtonPressed(drawing)
        setLikes()
    }
        
    fileprivate func setLikes() {
        let likeCount = drawing?.getLikes().count ?? 0
        if likeCount == 0 {
            likes?.text = ""
            likesButton?.isEnabled = false
        } else if likeCount == 1 {
            likesButton?.isEnabled = true
            likes?.text = "1 like"
        } else {
            likesButton?.isEnabled = true
            likes?.text = String(likeCount) + " likes"
        }
    }
}
