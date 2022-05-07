//
//  CurveStroke.swift
//  Colorue
//
//  Created by Dylan Wight on 5/7/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation


class CurveStroke: DrawingStroke {
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

    var points = pts
    points.append(point)
    context?.move(to: points.first!)

    if points.count == 2 {
      context?.addQuadCurve(to: points[1], control: points[0])
    } else {
      for i in 0...points.count - 1 {
        if i.isMultiple(of: 2) {
          context?.addQuadCurve(to: points[i + 1], control: points[i])
        } else {

        }
      }
    }



//    if (points.count == 2) {
//      context?.addQuadCurve(to: points.first!, control: point) // this is a line
//    } else {
//
//    }

//    else if (pts.count == 3) {
//    }

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
