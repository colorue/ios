//
//  DrawingCell.swift
//  Colorue
//
//  Created by Dylan Wight on 4/28/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import UIKit

class DrawingCell: UICollectionViewCell {
  @IBOutlet var imageView: UIImageView? {
    didSet {
      imageView?.layer.cornerRadius = 8
      imageView?.clipsToBounds = true
      imageView?.layer.borderColor = R.color.border()?.cgColor
      imageView?.layer.borderWidth = 0.5
    }
  }
  
  var drawing: Drawing? {
    didSet {
      imageView?.image = drawing?.image
    }
  }
}
