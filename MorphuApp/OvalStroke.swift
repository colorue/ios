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



    if pts.count == 2 {

      let ovalPath = CGMutablePath()

      // Third touch will be furthest or closest point of oval
      let center = pts.first!
      let radius1 = sqrt(center.distanceSquared(to: pts[1]))
      let radius2 = sqrt(center.distanceSquared(to: point))
      let origin = CGPoint(x: center.x - radius1, y: center.y - radius2)
      let frame = CGRect(origin: origin, size: CGSize(width: radius1 * 2, height: radius2 * 2))

      let angle = CGFloat.pi / 10
      let rotation = CGAffineTransform(translationX: frame.midX, y: frame.midY)
                                      .rotated(by: angle)
                                      .translatedBy(x: -frame.midX, y: -frame.midY)
      ovalPath.addEllipse(in: frame, transform: rotation)
      context?.addPath(ovalPath)
    } else {
      let center = pts.first ?? point
      let radius = pts.isEmpty ? 100.0 : sqrt(center.distanceSquared(to: point))
      let origin = CGPoint(x: center.x - radius, y: center.y - radius)
      let frame = CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))
      context?.addEllipse(in: frame)
    }
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
