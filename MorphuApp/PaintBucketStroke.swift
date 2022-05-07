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
    displayStroke()
  }

  override func changed(position: CGPoint) {
    drawDropperIndicator(position)
    displayStroke()
  }

  override func ended(position: CGPoint) {
    delegate?.drawingStroke(self, dumpedPaintAt: position)
  }
}
