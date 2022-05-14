//
//  CanvasView.swift
//  ColorCouch
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

protocol CanvasDelegate: AnyObject {
  func getCurrentColor() -> UIColor
  func getCurrentBrushSize() -> Float
  func getAlpha() -> CGFloat?
  func setUnderfingerView(_ underFingerImage: UIImage)
  func hideUnderFingerView()
  func showUnderFingerView()
  func setColor(_ color: UIColor?)
  func getKeyboardTool() -> ToolbarButton?
  func updateUndoButtons(undo: Bool, redo: Bool)
  func saveDrawing()
}

class CanvasView: UIView, UIGestureRecognizerDelegate {

  var drawingStroke: DrawingStroke?
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

  var baseDrawing: UIImage? {
    didSet {
      guard let baseDrawing = baseDrawing else {
        trash()
        return
      }
      undoStack.append(baseDrawing)
      imageView.image = baseDrawing
    }
  }

  var isEmpty: Bool {
    get {
      return undoStack.count < 2
    }
  }

  weak var delegate: CanvasDelegate?

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

    let tool = delegate.getKeyboardTool()?.type ?? .none
    // TODO: isDropper is only used for sizing, clean this up
    let isDropper = tool == .colorDropper || tool == .paintBucket
    if sender.state == .began {
      drawingStroke = DrawingStroke.makeStroke(type: tool)
      drawingStroke?.alpha = delegate.getAlpha() ?? 1.0
      drawingStroke?.color = delegate.getCurrentColor()
      drawingStroke?.brushSize = delegate.getCurrentBrushSize()
      drawingStroke?.actualSize = actualSize
      drawingStroke?.baseImage = undoStack.last
      drawingStroke?.delegate = self
      drawingStroke?.began(position: position)
      delegate.showUnderFingerView()
      setUnderFingerView(position, dropper: isDropper)
    } else if sender.state == .changed {
      drawingStroke?.changed(position: position)
      delegate.showUnderFingerView()
      setUnderFingerView(position, dropper: isDropper)
    } else if sender.state == .ended {
      drawingStroke?.ended(position: position)
      drawingStroke = nil
      delegate.hideUnderFingerView()
    }
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

  // MARK: External Methods

  func undo() {
    if let undone = undoStack.popLast() {
      redoStack.append(undone)
      imageView.image = undoStack.last
    }
  }

  func redo() {
    if let redone = redoStack.popLast() {
      undoStack.append(redone)
      imageView.image = undoStack.last
    }
  }

  func trash() {
    undoStack.removeAll()
    let clearCanvas = UIImage.getImageWithColor(UIColor.white, size: actualSize)
    undoStack.append(clearCanvas)
    imageView.image = clearCanvas
  }

  func getDrawing() -> UIImage {
    if let drawing = imageView.image {
      return drawing
    } else {
      return UIImage.getImageWithColor(UIColor.white, size: actualSize)
    }
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
}

// MARK: DrawingStrokeDelegate
extension CanvasView: DrawingStrokeDelegate {

  func drawingStroke(_ stroke: DrawingStroke, completedWith image: UIImage?) {
    addToUndoStack(image)
  }

  func drawingStroke(_ stroke: DrawingStroke, updatedWith image: UIImage?) {
    imageView.image = image
  }

  func drawingStroke(_ stroke: DrawingStroke, selectedColorAt point: CGPoint) -> UIColor? {
    let dropperColor = imageView.image?.color(atPosition: point) ?? .white
    if dropperColor != stroke.color {
      self.delegate?.setColor(dropperColor)
      Haptic.selectionChanged()
    }
    return dropperColor
  }

  func drawingStroke(_ stroke: DrawingStroke, dumpedPaintAt point: CGPoint) {
    imageView.image = stroke.baseImage
    let touchedColor = stroke.baseImage?.color(atPosition: point) ?? .white
    let mixedColor = UIColor.blendColor(touchedColor , withColor: stroke.color, percentMix: stroke.alpha)
    delegate?.getKeyboardTool()?.startAnimating()

    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
      guard let self = self else { return }
      let filledImage = stroke.baseImage?.pbk_imageByReplacingColorAt(Int(point.x), Int(point.y), withColor: mixedColor, tolerance: 5)
      DispatchQueue.main.async {
        self.addToUndoStack(filledImage)
        self.imageView.image = filledImage
        self.delegate?.getKeyboardTool()?.stopAnimating()
      }
    }
  }
}
