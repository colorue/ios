//
//  CurveStroke.swift
//  Colorue
//
//  Created by Dylan Wight on 5/7/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//
//  Helped by https://stackoverflow.com/questions/13719143/draw-graph-curves-with-uibezierpath

import Foundation


class CurveStroke: DrawingStroke {
  var nextPoint: CGPoint?

  override func began(position: CGPoint) {
    nextPoint = position
    displayStroke()
    drawCurves(to: position)
  }

  override func changed(position: CGPoint) {
    // Snap to starting point
    if let startingPt = pts.first, pts.count > 1,  position.distanceSquared(to: startingPt) < 100  {
      nextPoint = startingPt
      drawCurves(to: startingPt)
      isSnapped = true
    } else {
      nextPoint = position
      drawCurves(to: position)
      isSnapped = false
    }
    displayStroke()
  }

  override func ended(position: CGPoint) {
    if pts.count < 2 {
      delegate?.drawingStroke(self, updatedWith: baseImage)
    } else {
      path.removeAllPoints()
      pts.removeAll()
      let image = displayStroke()
      delegate?.drawingStroke(self, completedWith: image)
    }
  }

  override func start() {
    if let nextPoint = nextPoint {
      pts.append(nextPoint)
      displayStroke()
    }
  }

  func drawCurves(to point: CGPoint) {
    guard !pts.isEmpty else {
      return drawDot(point)
    }
    UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
    let context = UIGraphicsGetCurrentContext()

    var points = pts
    points.append(point)
    context?.move(to: points.first!)

    var p1 = points.first!

    if (points.count == 2) {
      context?.addLine(to: points[1])
    } else {
      var oldControlP: CGPoint?

      for i in 1..<points.count {
        let p2 = points[i]
        var p3: CGPoint?
        if i < points.count - 1 {
          p3 = points[i + 1]
        } else if (isSnapped) {
          p3 = points[1]
        }

        if (i == 1 && isSnapped) {
          oldControlP = antipodalFor(point: controlPointForPoints(p1: points[points.count - 2], p2: p1, next: p2), center: p1)
        }

        let newControlP = controlPointForPoints(p1: p1, p2: p2, next: p3)

        context?.addCurve(to: p2, control1: oldControlP ?? p1, control2: newControlP)

        p1 = p2
        oldControlP = antipodalFor(point: newControlP, center: p2)
      }
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


  /// located on the opposite side from the center point
  private func antipodalFor(point: CGPoint?, center: CGPoint?) -> CGPoint? {
    guard let p1 = point, let center = center else {
      return nil
    }
    let newX = 2 * center.x - p1.x
    let diffY = abs(p1.y - center.y)
    let newY = center.y + diffY * (p1.y < center.y ? 1 : -1)

    return CGPoint(x: newX, y: newY)
  }

  /// halfway of two points
  private func midPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2);
  }

  /// Find controlPoint2 for addCurve
  /// - Parameters:
  ///   - p1: first point of curve
  ///   - p2: second point of curve whose control point we are looking for
  ///   - next: predicted next point which will use antipodal control point for finded
  private func controlPointForPoints(p1: CGPoint, p2: CGPoint, next p3: CGPoint?) -> CGPoint {
    guard let p3 = p3 else {
      return p2
    }

    let leftMidPoint  = midPointForPoints(p1: p1, p2: p2)
    let rightMidPoint = midPointForPoints(p1: p2, p2: p3)

    var controlPoint = midPointForPoints(p1: leftMidPoint, p2: antipodalFor(point: rightMidPoint, center: p2)!)

    if p1.y.between(a: p2.y, b: controlPoint.y) {
      controlPoint.y = p1.y
    } else if p2.y.between(a: p1.y, b: controlPoint.y) {
      controlPoint.y = p2.y
    }


    let imaginContol = antipodalFor(point: controlPoint, center: p2)!
    if p2.y.between(a: p3.y, b: imaginContol.y) {
      controlPoint.y = p2.y
    }
    if p3.y.between(a: p2.y, b: imaginContol.y) {
      let diffY = abs(p2.y - p3.y)
      controlPoint.y = p2.y + diffY * (p3.y < p2.y ? 1 : -1)
    }

    // make lines easier
    controlPoint.x += (p2.x - p1.x) * 0.1

    return controlPoint
  }
}

extension CGFloat {
  func between(a: CGFloat, b: CGFloat) -> Bool {
    return self >= Swift.min(a, b) && self <= Swift.max(a, b)
  }
}
