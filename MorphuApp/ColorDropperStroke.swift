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
    guard let delegate = canvas.delegate else { return }
    Haptic.selectionChanged(prepare: true)
    delegate.setColor(canvas.imageView.image!.color(atPosition: position))
    delegate.setAlphaHigh()
    drawDropperIndicator(position)
    canvas.mergeCurrentStroke(true, image: currentStroke)
  }

  override func changed(position: CGPoint) {
    guard let delegate = canvas.delegate else { return }
    let dropperColor = canvas.imageView.image!.color(atPosition: position)
    if let color = dropperColor, color != delegate.getCurrentColor() {
      delegate.setColor(color)
      Haptic.selectionChanged(prepare: true)
    }
    drawDropperIndicator(position)
    canvas.mergeCurrentStroke(true, image: currentStroke)
  }

  override func ended(position: CGPoint) {
    guard let delegate = canvas.delegate else { return }
    Haptic.selectionChanged()
    delegate.setKeyboardState(nil)
    canvas.clearCurrentStroke()
  }
}
