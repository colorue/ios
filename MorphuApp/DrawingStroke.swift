//
//  DrawingStroke.swift
//  Colorue
//
//  Created by Dylan Wight on 5/6/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

class DrawingTool {

  let positionIndicator = R.image.positionIndicator()!

  var pts: [CGPoint] = [CGPoint]()
  var path: UIBezierPath = UIBezierPath()
  var canvas: CanvasView
  var color: UIColor
  var alpha: CGFloat
  var brushSize: Float

  init(canvas: CanvasView, color: UIColor, alpha: CGFloat, brushSize: Float) {
    self.canvas = canvas
    self.color = color
    self.alpha = alpha
    self.brushSize = brushSize
  }

  func handleDrag(position: CGPoint, state: UIGestureRecognizerState) {
    curveTouch(position: position, state: state)
  }

  func curveTouch(position: CGPoint, state: UIGestureRecognizerState) {
    guard let delegate = canvas.delegate else { return }

    if state == .began {
      print("curveTouch .began")
      pts.removeAll()
      pts.append(position)
      finishStroke()
      delegate.showUnderFingerView()
      canvas.setUnderFingerView(position, dropper: false)
    } else if state == .changed {
      print("curveTouch .changed", pts.count)
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
      canvas.setUnderFingerView(position, dropper: false)
    } else if state == .ended {
      print("curveTouch .ended")
      pts.append(position)
      completeCurve()
      delegate.hideUnderFingerView()
    }
  }

  func finishStroke() {
    if !pts.isEmpty {
      UIGraphicsBeginImageContextWithOptions(canvas.actualSize, false, 1.0)
      canvas.currentStroke?.draw(at: CGPoint.zero)

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
      canvas.currentStroke = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
    }
  }

  func completeCurve () {
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
    canvas.addToUndoStack(canvas.imageView.image)
    canvas.currentStroke = nil
  }

  func drawCurve() {
    print("drawCurve")
    UIGraphicsBeginImageContextWithOptions(canvas.actualSize, false, 1.0)
    canvas.currentStroke?.draw(at: CGPoint.zero)
    color.setStroke()
    path.lineWidth = CGFloat(brushSize) * canvas.resizeScale
    path.lineCapStyle = CGLineCap.round
    path.stroke()
    canvas.currentStroke = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }

  func drawDot(_ position: CGPoint) {
    print("drawDot")
    UIGraphicsBeginImageContextWithOptions(canvas.actualSize, false, 1.0)
    let context = UIGraphicsGetCurrentContext()
    context?.move(to: CGPoint(x: position.x, y: position.y))
    context?.addLine(to: CGPoint(x: position.x, y: position.y))
    context?.setLineCap(CGLineCap.round)
    context?.setLineWidth(CGFloat(brushSize) * canvas.resizeScale)
    context?.setStrokeColor(red: color.coreImageColor!.red, green: color.coreImageColor!.green, blue: color.coreImageColor!.blue, alpha: 1.0)
    context?.strokePath()
    context?.flush()
    canvas.currentStroke = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }

  func drawDropperIndicator(_ point: CGPoint) {
    UIGraphicsBeginImageContextWithOptions(canvas.actualSize, false, 1.0)
    let context = UIGraphicsGetCurrentContext()
    positionIndicator.draw(at: CGPoint(x: point.x - (positionIndicator.size.width / 2), y: point.y - (positionIndicator.size.height / 2)))
    context?.strokePath()
    context?.flush()
    canvas.currentStroke = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
}

class DefaultTool: DrawingTool {
  override func handleDrag (position: CGPoint, state: UIGestureRecognizerState) {
    curveTouch(position: position, state: state)
  }
}

class PaintBucketTool: DrawingTool {
  override func handleDrag (position: CGPoint, state: UIGestureRecognizerState) {
    guard let delegate = canvas.delegate else { return }

    if state == .began {
      delegate.showUnderFingerView()
      drawDropperIndicator(position)
      canvas.setUnderFingerView(position, dropper: true)
    } else if state == .changed {
      drawDropperIndicator(position)
      canvas.setUnderFingerView(position, dropper: true)
    } else if state == .ended {
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
}

class BullsEyeTool: DrawingTool {
  override func handleDrag (position: CGPoint, state: UIGestureRecognizerState) {
    if canvas.delegate?.isDrawingOn() ?? false {
      curveTouch(position: position, state: state)
    } else {
      bullsEye(position, state: state)
    }
  }

  func bullsEye(_ position: CGPoint, state: UIGestureRecognizerState) {
    guard let delegate = canvas.delegate else { return }

    if state == .began {
      drawDot(position)
      canvas.mergeCurrentStroke(true)
      delegate.showUnderFingerView()
      canvas.setUnderFingerView(position, dropper: false)
    } else if state == .changed {
      drawDot(position)
      delegate.showUnderFingerView()
      canvas.setUnderFingerView(position, dropper: false)
    } else if state == .ended {
      canvas.addToUndoStack(canvas.imageView.image)
      canvas.currentStroke = nil
      canvas.mergeCurrentStroke(false)
      canvas.undo()
      _ = canvas.redoStack.popLast()
      delegate.hideUnderFingerView()
    }
  }
}

class ColorDropperTool: DrawingTool {
  override func handleDrag (position: CGPoint, state: UIGestureRecognizerState) {
    guard let delegate = canvas.delegate else { return }

    if state == .began {
      Haptic.selectionChanged(prepare: true)
      delegate.setColor(canvas.imageView.image!.color(atPosition: position))
      delegate.showUnderFingerView()
      delegate.setAlphaHigh()
      drawDropperIndicator(position)
      canvas.setUnderFingerView(position, dropper: true)
    } else if state == .changed {
      let dropperColor = canvas.imageView.image!.color(atPosition: position)
      if let color = dropperColor, color != delegate.getCurrentColor() {
        delegate.setColor(color)
        Haptic.selectionChanged(prepare: true)
      }
      drawDropperIndicator(position)
      canvas.setUnderFingerView(position, dropper: true)
    } else if state == .ended {
      Haptic.selectionChanged()
      delegate.setKeyboardState(nil)
      delegate.hideUnderFingerView()
      canvas.currentStroke = nil
      canvas.mergeCurrentStroke(false)
    }
  }
}
