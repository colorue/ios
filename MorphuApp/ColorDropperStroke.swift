//
//  ColorDropperStroke.swift
//  Colorue
//
//  Created by Dylan Wight on 5/6/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

class ColorDropperStroke: DrawingStroke {

  override func began(position: CGPoint) {
    delegate?.pickColorAt(position: position, currentColor: color)
    drawDropperIndicator(position)
    delegate?.mergeCurrentStroke(true, image: currentStroke)
  }

  override func changed(position: CGPoint) {
    delegate?.pickColorAt(position: position, currentColor: color)
    drawDropperIndicator(position)
    delegate?.mergeCurrentStroke(true, image: currentStroke)
  }

  override func ended(position: CGPoint) {
    self.delegate?.clearCurrentStroke()
  }
}
