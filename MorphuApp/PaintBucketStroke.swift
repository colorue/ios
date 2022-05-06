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
  }

  override func changed(position: CGPoint) {
    drawDropperIndicator(position)
    canvas.setUnderFingerView(position, dropper: true)
  }

  override func ended(position: CGPoint) {
    guard let delegate = canvas.delegate else { return }
    canvas.currentStroke = nil
    delegate.getKeyboardTool()?.startAnimating()
    delegate.hideUnderFingerView()
    canvas.mergeCurrentStroke(false)
    let touchedColor = canvas.imageView.image!.color(atPosition: position) ?? .white
    let mixedColor = UIColor.blendColor(touchedColor , withColor: delegate.getCurrentColor(), percentMix: delegate.getAlpha() ?? 1.0)

    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
      let filledImage = self.canvas.undoStack.last?.pbk_imageByReplacingColorAt(Int(position.x), Int(position.y), withColor: mixedColor, tolerance: 5)
      self.canvas.addToUndoStack(filledImage)
      DispatchQueue.main.async {
        self.canvas.mergeCurrentStroke(false)
        delegate.getKeyboardTool()?.stopAnimating()
      }
    }
  }
}
