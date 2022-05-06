//
//  DrawingStroke.swift
//  Colorue
//
//  Created by Dylan Wight on 5/6/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

protocol DrawingStrokeDelegate {
  func mergeCurrentStroke(_ alpha: Bool, image: UIImage?)
  func paintAt(position: CGPoint, color: UIColor, alpha: CGFloat)
}

class DrawingStroke {

  let positionIndicator = R.image.positionIndicator()!
  var currentStroke: UIImage?

  var pts = [CGPoint]()
  var path = UIBezierPath()
  var canvas: CanvasView
  var color: UIColor
  var alpha: CGFloat
  var brushSize: Float

  static func makeStroke (canvas: CanvasView, type: KeyboardToolState) -> DrawingStroke {
    switch (type) {
    case .none:
      return DefaultStroke(canvas: canvas)
    case .colorDropper:
      return ColorDropperStroke(canvas: canvas)
    case .paintBucket:
      return PaintBucketStroke(canvas: canvas)
    case .bullsEye:
      return AimModeStroke(canvas: canvas)
    }
  }

  init(canvas: CanvasView) {
    self.canvas = canvas
    self.color = canvas.delegate!.getCurrentColor()
    self.alpha = canvas.delegate!.getAlpha()!
    self.brushSize = canvas.delegate!.getCurrentBrushSize()
  }

  func began(position: CGPoint) {
    pts.append(position)
    finishStroke()
    canvas.mergeCurrentStroke(true, image: currentStroke)
  }

  func changed(position: CGPoint) {
    pts.append(position)
    if pts.count == 5 {
      pts[3] = CGPoint(x: (pts[2].x + pts[4].x)/2.0, y: (pts[2].y + pts[4].y)/2.0)
      path.move(to: pts[0])
      path.addCurve(to: pts[3], controlPoint1: pts[1], controlPoint2: pts[2])
      self.drawCurve()
      pts[0] = pts[3]
      pts[1] = pts[4]
      pts.removeLast(3)
    }
    canvas.mergeCurrentStroke(true, image: currentStroke)
  }

  func ended(position: CGPoint) {
    pts.append(position)
    if pts.count >= 5 {
      pts[3] = CGPoint(x: (pts[2].x + pts[4].x)/2.0, y: (pts[2].y + pts[4].y)/2.0)
      path.move(to: pts[0])
      path.addCurve(to: pts[3], controlPoint1: pts[1], controlPoint2: pts[2])
      self.drawCurve()
      pts[0] = pts[3]
      pts[1] = pts[4]
      pts.removeLast(3)
    } else {
      self.finishStroke()
    }
    path.removeAllPoints()
    pts.removeAll()
    canvas.mergeCurrentStroke(true, image: currentStroke)
    canvas.addToUndoStack(canvas.imageView.image)
  }

  func end() {

  }

  // MARK: utility functions

  func finishStroke() {
    if !pts.isEmpty {
      UIGraphicsBeginImageContextWithOptions(canvas.actualSize, false, 1.0)
      currentStroke?.draw(at: CGPoint.zero)

      let context = UIGraphicsGetCurrentContext()
      if pts.count <= 2 {
        context?.move(to: CGPoint(x: pts.first!.x, y: pts.first!.y))
        context?.addLine(to: CGPoint(x: pts.last!.x, y: pts.last!.y))
      } else if pts.count == 3 {
        context?.move(to: CGPoint(x: pts[0].x, y: pts[0].y))
        context?.addQuadCurve(to: CGPoint(x: pts[1].x, y: pts[1].y), control: CGPoint(x: pts[2].x, y: pts[2].y))
      } else if pts.count == 4 {
        context?.move(to: CGPoint(x: pts[0].x, y: pts[0].y))
        context?.addQuadCurve(to: CGPoint(x: pts[1].x, y: pts[1].y), control: CGPoint(x: pts[3].x, y: pts[3].y))
      }

      context?.setLineCap(CGLineCap.round)
      context?.setLineWidth(CGFloat(brushSize) * canvas.resizeScale)
      context?.setStrokeColor(red: color.coreImageColor!.red, green: color.coreImageColor!.green, blue: color.coreImageColor!.blue, alpha: 1.0)

      context?.strokePath()
      context?.flush()
      currentStroke = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
    }
  }

  func drawCurve() {
    UIGraphicsBeginImageContextWithOptions(canvas.actualSize, false, 1.0)
    currentStroke?.draw(at: CGPoint.zero)
    color.setStroke()
    path.lineWidth = CGFloat(brushSize) * canvas.resizeScale
    path.lineCapStyle = CGLineCap.round
    path.stroke()
    currentStroke = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }

  func drawDot(_ position: CGPoint) {
    UIGraphicsBeginImageContextWithOptions(canvas.actualSize, false, 1.0)
    let context = UIGraphicsGetCurrentContext()
    context?.move(to: CGPoint(x: position.x, y: position.y))
    context?.addLine(to: CGPoint(x: position.x, y: position.y))
    context?.setLineCap(CGLineCap.round)
    context?.setLineWidth(CGFloat(brushSize) * canvas.resizeScale)
    context?.setStrokeColor(red: color.coreImageColor!.red, green: color.coreImageColor!.green, blue: color.coreImageColor!.blue, alpha: 1.0)
    context?.strokePath()
    context?.flush()
    currentStroke = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }

  func drawDropperIndicator(_ point: CGPoint) {
    UIGraphicsBeginImageContextWithOptions(canvas.actualSize, false, 1.0)
    let context = UIGraphicsGetCurrentContext()
    positionIndicator.draw(at: CGPoint(x: point.x - (positionIndicator.size.width / 2), y: point.y - (positionIndicator.size.height / 2)))
    context?.strokePath()
    context?.flush()
    currentStroke = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
}
