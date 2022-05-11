//
//  AimModeStroke.swift
//  Colorue
//
//  Created by Dylan Wight on 5/6/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

class AimModeStroke: DrawingStroke {

  override func began(position: CGPoint) {
    if isDrawing {
      super.began(position: position)
    } else {
      drawDot(position)
      displayStroke()
      
    }
  }

  override func changed(position: CGPoint) {
    if isDrawing {
      super.changed(position: position)
    } else {
      drawDot(position)
      displayStroke()
    }
  }

  override func ended(position: CGPoint) {
    if isDrawing {
      super.ended(position: position)
    } else {
      delegate?.drawingStroke(self, updatedWith: baseImage)
    }
  }

  override func onPress() {
    super.onPress()
    isDrawing = true
  }

  override func onRelease() {
    super.onRelease()
    Haptic.selectionChanged()
    isDrawing = false
    path.removeAllPoints()
    pts.removeAll()
    if let image = displayStroke() {
      baseImage = image
      delegate?.drawingStroke(self, completedWith: image)
    }
  }
}
