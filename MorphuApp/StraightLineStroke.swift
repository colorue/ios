//
//  LineStroke.swift
//  Colorue
//
//  Created by Dylan Wight on 5/6/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

class StraightLineStroke: DrawingStroke {
  var nextPoint: CGPoint?

  override func began(position: CGPoint) {
    nextPoint = position
    displayStroke()
    drawLines(to: position)
  }

  override func changed(position: CGPoint) {
    // Snap to starting point
    if let startingPt = pts.first, pts.count > 1,  position.distanceSquared(to: startingPt) < 100  {
      nextPoint = startingPt
      drawLines(to: startingPt)
    } else {
      nextPoint = position
      drawLines(to: position)
    }
    displayStroke()
  }

  override func ended(position: CGPoint) {
    if let delegate = delegate, delegate.isDrawingOn {
    } else {
      delegate?.drawingStroke(self, updatedWith: baseImage)
    }
    path.removeAllPoints()
    pts.removeAll()
    let image = displayStroke()
    delegate?.drawingStroke(self, completedWith: image)
  }

  override func start() {
    if let nextPoint = nextPoint {
      pts.append(nextPoint)
      displayStroke()
    }
  }

  func drawLines(to point: CGPoint) {
    guard !pts.isEmpty else {
      return drawDot(point)
    }
    UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
    let context = UIGraphicsGetCurrentContext()
    context?.move(to: point)
    for pt in pts.reversed() {
      context?.addLine(to: pt)
    }
    context?.setLineCap(.round)
    context?.setLineJoin(.round)
    context?.setLineWidth(CGFloat(brushSize) * resizeScale)
    context?.setStrokeColor(red: color.coreImageColor!.red, green: color.coreImageColor!.green, blue: color.coreImageColor!.blue, alpha: 1.0)
    context?.strokePath()
    context?.flush()
    currentStroke = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
}