//
//  OvalStroke.swift
//  Colorue
//
//  Created by Dylan Wight on 5/7/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

class OvalStroke: DrawingStroke {
  var nextPoint: CGPoint?

  override func began(position: CGPoint) {
    nextPoint = position
    drawCircle(to: position)
    displayStroke()
  }

  override func changed(position: CGPoint) {
    nextPoint = position
    drawCircle(to: position)
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

  func drawCircle(to point: CGPoint) {
    UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
    let context = UIGraphicsGetCurrentContext()
    let center = pts.first ?? point
    let radius = pts.isEmpty ? 100.0 : sqrt(center.distanceSquared(to: point))
    let origin = CGPoint(x: center.x - radius, y: center.y - radius)
    let frame = CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))
    context?.addEllipse(in: frame)
    context?.setLineCap(.round)
    context?.setLineJoin(.round)
    context?.setLineWidth(CGFloat(brushSize) * resizeScale)
    context?.setStrokeColor(color)
    context?.strokePath()
    context?.flush()
    currentStroke = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
}
