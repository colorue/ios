//
//  CanvasView.swift
//  ColorCouch
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

protocol CanvasDelegate {
  func getCurrentColor() -> UIColor
  func getCurrentBrushSize() -> Float
  func getAlpha() -> CGFloat?
  func setAlphaHigh()
  func setUnderfingerView(_ underFingerImage: UIImage)
  func hideUnderFingerView()
  func showUnderFingerView()
  func setColor(_ color: UIColor?)
  func getKeyboardTool() -> ToolbarButton?
  func setKeyboardState(_ tool: ToolbarButton?)
  func isDrawingOn() -> Bool
  func updateUndoButtons(undo: Bool, redo: Bool)
  func saveDrawing()
}

class CanvasView: UIView, UIGestureRecognizerDelegate {

  var path: UIBezierPath = UIBezierPath()
  var pts: [CGPoint] = [CGPoint]()

  var drawingStroke: DrawingStroke?

  var lastPoint: CGPoint?
  var currentStroke: UIImage?
  var undoStack = [UIImage]() {
    didSet {
      delegate?.updateUndoButtons(undo: !isEmpty, redo: !redoStack.isEmpty)
      delegate?.saveDrawing()
    }
  }
  var redoStack = [UIImage]()  {
    didSet {
      delegate?.updateUndoButtons(undo: !isEmpty, redo: !redoStack.isEmpty)
    }
  }
  var imageView = UIImageView()
  let resizeScale: CGFloat = 2.0
  var actualSize = CGSize()
  fileprivate let prefs = UserDefaults.standard

  var baseDrawing: UIImage? {
    didSet {
      guard let baseDrawing = baseDrawing else {
        trash()
        return
      }
      undoStack.append(baseDrawing)
      mergeCurrentStroke(false)
    }
  }

  var isEmpty: Bool {
    get {
      return undoStack.count < 2
    }
  }

  var delegate: CanvasDelegate?


  // MARK: Initializer Methods

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    displayCanvas()
  }

  override init (frame: CGRect) {
    super.init(frame : frame)
    displayCanvas()
  }

  fileprivate func displayCanvas() {
    actualSize = CGSize(width: frame.width * resizeScale, height: frame.height * resizeScale)
    imageView.frame = CGRect(origin: CGPoint.zero, size: frame.size)
    addSubview(imageView)

    let drag = UILongPressGestureRecognizer(target: self, action: #selector(CanvasView.handleDrag(_:)))
    drag.minimumPressDuration = 0.0
    drag.delegate = self
    addGestureRecognizer(drag)
  }

  // MARK: Controll Methods

  @objc fileprivate func handleDrag(_ sender: UILongPressGestureRecognizer) {
    guard let delegate = delegate else { return }
    let position = CGPoint(x: sender.location(in: imageView).x * resizeScale, y: sender.location(in: imageView).y * resizeScale)
    mergeCurrentStroke(true)

    let tool = delegate.getKeyboardTool()?.type ?? .none
    // isDropper is only used for sizing, I'd like to clean it up
    let isDropper = tool == .colorDropper || tool == .paintBucket
    if sender.state == .began {
      delegate.showUnderFingerView()
      setUnderFingerView(position, dropper: isDropper)
      drawingStroke = DrawingStroke.makeStroke(canvas: self, type: tool)
      drawingStroke?.began(position: position)
      mergeCurrentStroke(true)
    } else if sender.state == .changed {
      drawingStroke?.changed(position: position)
      delegate.showUnderFingerView()
      setUnderFingerView(position, dropper: isDropper)
    } else if sender.state == .ended {
      drawingStroke?.ended(position: position)
      drawingStroke = nil
      currentStroke = nil
      delegate.hideUnderFingerView()
      mergeCurrentStroke(false)
    }
  }

  func completeCurve () {
    drawingStroke?.completeCurve()
  }

  func setUnderFingerView(_ position: CGPoint, dropper: Bool) {
    guard let delegate = delegate else { return }

    let underFingerSize: CGSize

    let maxUnderFinger = 400.0
    let minUnderFinger = 200.0

    let ceilingSize = 80.0
    let baseSize = 10.0

    if dropper {
      underFingerSize = CGSize(width: minUnderFinger, height: minUnderFinger)
    } else {
      let brushSize = Double(delegate.getCurrentBrushSize())

      if (brushSize > ceilingSize) {
        underFingerSize = CGSize(width: maxUnderFinger, height: maxUnderFinger)
      } else if (brushSize < baseSize){
        underFingerSize = CGSize(width: minUnderFinger, height: minUnderFinger)
      } else {
        let underFinger = ((brushSize - baseSize) / ceilingSize) * (maxUnderFinger - minUnderFinger) + minUnderFinger
        underFingerSize = CGSize(width: underFinger, height: underFinger)
      }
    }
    delegate.setUnderfingerView(imageView.image!.cropToSquare(position, cropSize: underFingerSize))
  }


  // MARK: Drawing Methods



  func drawCurve() {
    guard let delegate = delegate else { return }

    UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
    currentStroke?.draw(at: CGPoint.zero)
    delegate.getCurrentColor().setStroke()
    path.lineWidth = CGFloat(delegate.getCurrentBrushSize()) * resizeScale
    path.lineCapStyle = CGLineCap.round
    path.stroke()
    currentStroke = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }

  func mergeCurrentStroke(_ alpha: Bool) {
    UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
    undoStack.last?.draw(at: CGPoint.zero)

    if alpha {
      currentStroke?.draw(at: CGPoint.zero, blendMode: .normal, alpha: delegate?.getAlpha() ?? 1.0)
    } else {
      currentStroke?.draw(at: CGPoint.zero)
    }
    imageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }

  func addToUndoStack(_ image: UIImage?) {
    if let image = image {
      if undoStack.count <= 64 {
        undoStack.append(image)
      } else {
        undoStack.remove(at: 0)
        undoStack.append(image)
      }
      redoStack.removeAll()
    }
  }

  // MARK: External Methods

  func undo() {
    if let undone = undoStack.popLast() {
      redoStack.append(undone)
      mergeCurrentStroke(false)
    }
  }

  func redo() {
    if let redone = redoStack.popLast() {
      undoStack.append(redone)
      mergeCurrentStroke(false)
    }
  }

  func trash() {
    undoStack.removeAll()
    currentStroke = (UIImage.getImageWithColor(UIColor.white, size: actualSize))
    mergeCurrentStroke(false)
    addToUndoStack(imageView.image)
    currentStroke = nil
  }

  func getDrawing() -> UIImage {
    if let drawing = imageView.image {
      return drawing
    } else {
      return UIImage.getImageWithColor(UIColor.white, size: actualSize)
    }
  }
}
