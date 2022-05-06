//
//  PaintBucketStroke.swift
//  Colorue
//
//  Created by Dylan Wight on 5/6/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

class PaintBucketStroke: DrawingStroke {
  override func began(position: CGPoint) {
    drawDropperIndicator(position)
    canvas.mergeCurrentStroke(true, image: currentStroke)
  }

  override func changed(position: CGPoint) {
    drawDropperIndicator(position)
    canvas.mergeCurrentStroke(true, image: currentStroke)
  }

  override func ended(position: CGPoint) {
    canvas.paintAt(position: position, color: color, alpha: alpha)
  }
}
