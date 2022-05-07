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
    if let delegate = delegate, delegate.isDrawingOn() {
      super.began(position: position)
    } else {
      drawDot(position)
      delegate?.mergeCurrentStroke(true, image: currentStroke)
    }
  }

  override func changed(position: CGPoint) {
    if let delegate = delegate, delegate.isDrawingOn() {
      super.changed(position: position)
    } else {
      drawDot(position)
      delegate?.mergeCurrentStroke(true, image: currentStroke)
    }
  }

  override func ended(position: CGPoint) {
    if let delegate = delegate, delegate.isDrawingOn() {
      super.ended(position: position)
    } else {
      delegate?.clearCurrentStroke()
    }
  }

  override func end() {
    path.removeAllPoints()
    pts.removeAll()
    delegate?.mergeCurrentStroke(true, image: currentStroke)
    delegate?.addToUndoStack(nil)
  }
}
