//
//  InboxDrawingCell.swift
//  Colorue
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Kingfisher
import ActiveLabel

protocol DrawingCellDelegate: class, ActiveLabelDelegate {
    func presentDrawingActions(_ drawing: Drawing)
    func likeButtonPressed(_ drawing: Drawing)
    func userButtonPressed(_ drawing: Drawing)
    func likesButtonPressed(_ drawing: Drawing)
    func commentsButtonPressed(_ drawing: Drawing)
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
    
    @IBOutlet weak var captionLabel: ActiveLabel? {
        didSet {
            captionLabel?.font = R.font.openSans(size: 12.0)
            captionLabel?.textColor = Theme.infoText
        }
    }
    
    
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
            guard let color = color else { return }
            
            uploadButton?.tintColor = color
            likeButton?.tintColor = color
            likes?.textColor = color
            commentCount?.textColor = color
            captionLabel?.hashtagColor = color
            captionLabel?.mentionColor = color
        }
    }
    
    var delegate: DrawingCellDelegate? {
        didSet {
            uploadButton?.addTarget(self, action: #selector(DrawingCell.presentDrawingActions(_:)), for: .touchUpInside)
            likeButton?.addTarget(self, action: #selector(DrawingCell.likeButtonPressed(_:)), for: .touchUpInside)
            userButton?.addTarget(self, action: #selector(DrawingCell.userButtonPressed(_:)), for: .touchUpInside)
            likesButton?.addTarget(self, action: #selector(DrawingCell.likesButtonPressed(_:)), for: .touchUpInside)
            commentsButton?.addTarget(self, action: #selector(DrawingCell.commentsButtonPressed(_:)), for: .touchUpInside)
            
            captionLabel?.delegate = delegate
        }
    }
    
    var drawing: Drawing? {
        didSet {
            guard let drawing = drawing else { return }
            
            if let url = drawing.imageUrl {
                drawingImage?.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.2))],
                                                 completionHandler: { (image, error, cacheType, imageURL) -> () in
                    self.drawing?.image = image ?? UIImage()
                })
            }
            
            profileImage?.kf.setImage(with: URL(string: drawing.user.profileURL), placeholder: nil, options: [.transition(.fade(0.2))], completionHandler: nil)
            creator?.text = drawing.user.username
            timeCreated?.text = drawing.timeStamp.timeSince
            likeButton?.isSelected = drawing.liked(API.sharedInstance.getActiveUser())
            captionLabel?.text = drawing.caption
            
            if drawing.comments.count == 1 {
                commentCount?.text = "1 comment"
            } else {
                commentCount?.text = String(drawing.comments.count) + " comments"
            }
            setLikes()
        }
    }
    
    @objc fileprivate func presentDrawingActions(_ sender: UIButton) {
        guard let drawing = drawing else { return }
        delegate?.presentDrawingActions(drawing)
    }
    
    @objc fileprivate func userButtonPressed(_ sender: UIButton) {
        guard let drawing = drawing else { return }
        delegate?.userButtonPressed(drawing)
    }
    
    @objc fileprivate func likesButtonPressed(_ sender: UIButton) {
        guard let drawing = drawing else { return }
        delegate?.likesButtonPressed(drawing)
    }
    
    @objc fileprivate func commentsButtonPressed(_ sender: UIButton) {
        guard let drawing = drawing else { return }
        delegate?.commentsButtonPressed(drawing)
    }
    
    @objc fileprivate func likeButtonPressed(_ sender: UIButton) {
        guard let drawing = drawing else { return }
        
        sender.isSelected = !sender.isSelected
        delegate?.likeButtonPressed(drawing)
        setLikes()
    }
        
    fileprivate func setLikes() {
        let likeCount = drawing?.likes.count ?? 0
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
