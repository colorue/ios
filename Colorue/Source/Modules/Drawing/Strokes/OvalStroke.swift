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
    if pts.isEmpty  {
      delegate?.drawingStroke(self, updatedWith: baseImage)
    } else {
      path.removeAllPoints()
      pts.removeAll()
      let image = displayStroke()
      delegate?.drawingStroke(self, completedWith: image)
    }
  }

  override func onPress() {
    super.onPress()

    guard let nextPoint = nextPoint  else { return }
    if pts.count > 1 {
      // Turn back into circle from oval
      _ = pts.popLast()
    }
    pts.append(nextPoint)
    changed(position: nextPoint)
  }

  func drawCircle(to point: CGPoint) {

    guard let center =  pts.first else {
      return  drawDropperIndicator(point)
    }
    UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
    let context = UIGraphicsGetCurrentContext()
    if pts.count > 1 {
      // Draw oval
      let ovalPath = CGMutablePath()
      let radius2 = sqrt(center.distanceSquared(to: pts[1]))
      var radius1 = sqrt(center.distanceSquared(to: point))
      if (abs(radius2 - radius1) < radius2 / 20.0) {
        // Snap to circle
        radius1 = radius2
        isSnapped = true
      } else {
        isSnapped = false
      }
      let origin = CGPoint(x: center.x - radius1, y: center.y - radius2)
      let angle = atan2(point.y - center.y, point.x - center.x)

      let frame = CGRect(origin: origin, size: CGSize(width: radius1 * 2, height: radius2 * 2))
      let rotation = CGAffineTransform(translationX: frame.midX, y: frame.midY)
                                      .rotated(by: angle)
                                      .translatedBy(x: -frame.midX, y: -frame.midY)
      ovalPath.addEllipse(in: frame, transform: rotation)
      context?.addPath(ovalPath)
    } else {
      // Draw circle
      let radius = sqrt(center.distanceSquared(to: point))
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
