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
    color = delegate?.drawingStroke(self, selectedColorAt: position) ?? color
    drawDropperIndicator(position)
    displayStroke()
  }

  override func changed(position: CGPoint) {
    color = delegate?.drawingStroke(self, selectedColorAt: position) ?? color
    drawDropperIndicator(position)
    displayStroke()
  }

  override func ended(position: CGPoint) {
    delegate?.drawingStroke(self, updatedWith: baseImage)
  }
}
