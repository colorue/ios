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
      imageView?.layer.cornerRadius = 12
      imageView?.clipsToBounds = true
      imageView?.layer.borderColor = Theme.divider.cgColor
      imageView?.layer.borderWidth = 0.5
    }
  }
  
  var drawing: Drawing? {
    didSet {
      if let base64 = drawing?.base64 {
        imageView?.image = UIImage.fromBase64(base64)
      }
    }
  }
}
