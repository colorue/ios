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
      canvas.mergeCurrentStroke(true)
    }
  }

  override func changed(position: CGPoint) {
    if canvas.delegate?.isDrawingOn() ?? false {
      super.changed(position: position)
    } else {
      drawDot(position)
    }
  }

  override func ended(position: CGPoint) {
    if canvas.delegate?.isDrawingOn() ?? false {
      super.changed(position: position)
    } else {
      canvas.addToUndoStack(canvas.imageView.image)
      canvas.mergeCurrentStroke(false)
      canvas.undo()
      _ = canvas.redoStack.popLast()
    }
  }
}
