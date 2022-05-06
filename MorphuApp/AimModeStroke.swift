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
    if canvas.delegate?.isDrawingOn() ?? false {
      super.began(position: position)
    } else {
      drawDot(position)
      canvas.mergeCurrentStroke(true, image: currentStroke)
    }
  }

  override func changed(position: CGPoint) {
    if canvas.delegate?.isDrawingOn() ?? false {
      super.changed(position: position)
    } else {
      drawDot(position)
      canvas.mergeCurrentStroke(true, image: currentStroke)
    }
  }

  override func ended(position: CGPoint) {
    if canvas.delegate?.isDrawingOn() ?? false {
      super.ended(position: position)
    } else {
      canvas.clearCurrentStroke()
    }
  }

  override func end() {
    path.removeAllPoints()
    pts.removeAll()
    canvas.mergeCurrentStroke(true, image: currentStroke)
    canvas.addToUndoStack(canvas.imageView.image)
  }
}
