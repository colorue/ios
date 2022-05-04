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
    func getKeyboardState() -> KeyboardToolState
    func setKeyboardState(_ state: KeyboardToolState)
    func startPaintBucketSpinner()
    func stopPaintBucketSpinner()
}

class CanvasView: UIView, UIGestureRecognizerDelegate {
    
    fileprivate var path: UIBezierPath = UIBezierPath()
    var pts: [CGPoint] = [CGPoint]()

    fileprivate var lastPoint: CGPoint?
    fileprivate var currentStroke: UIImage?
    fileprivate var undoStack = [UIImage]()
    fileprivate var redoStack = [UIImage]()
    fileprivate var imageView = UIImageView()
    fileprivate let positionIndicator = R.image.positionIndicator()!
    fileprivate let resizeScale: CGFloat = 2.0
    fileprivate var actualSize = CGSize()
    fileprivate let prefs = UserDefaults.standard
    fileprivate let watermark = R.image.watermark()!

    
    var baseDrawing: UIImage? {
        didSet {
            guard let baseDrawing = baseDrawing else {
                trash()
                return
            }
            undoStack.removeAll()
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

//        let watermarkView = UIImageView(image: watermark)
//      watermarkView.frame = CGRect(origin: CGPoint(x: imageView.frame.width - watermark.size.width, y:0), size: watermark.size)
//        addSubview(watermarkView)
    }
    
    
    // MARK: Controll Methods
    
    @objc fileprivate func handleDrag(_ sender: UILongPressGestureRecognizer) {
        guard let delegate = delegate else { return }
        
        let actualPosition = CGPoint(x: sender.location(in: imageView).x * resizeScale, y: sender.location(in: imageView).y * resizeScale)
        mergeCurrentStroke(true)
        
        switch (delegate.getKeyboardState()) {
        case .none:
            curveTouch(actualPosition, state: sender.state)
        case .colorDropper:
            dropperTouch(actualPosition, state: sender.state)
        case .paintBucket:
            paintBucket(actualPosition, state: sender.state)
        case .bullsEye:
            bullsEye(actualPosition, state: sender.state)
        }
    }
    
    fileprivate func paintBucket(_ position: CGPoint, state: UIGestureRecognizerState) {
        guard let delegate = delegate else { return }
        
        if state == .began {
            delegate.showUnderFingerView()
            drawDropperIndicator(position)
            setUnderFingerView(position, dropper: true)
        } else if state == .changed {
            drawDropperIndicator(position)
            setUnderFingerView(position, dropper: true)
        } else if state == .ended {
            currentStroke = nil
            delegate.startPaintBucketSpinner()
            delegate.hideUnderFingerView()
            mergeCurrentStroke(false)

            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                let filledImage = self.undoStack.last?.pbk_imageByReplacingColorAt(Int(position.x), Int(position.y), withColor: delegate.getCurrentColor(), tolerance: 5)
                self.addToUndoStack(filledImage)
                DispatchQueue.main.async {
                    self.mergeCurrentStroke(false)
                    delegate.stopPaintBucketSpinner()
                }
            }
        }
    }
    
    fileprivate func dropperTouch(_ position: CGPoint, state: UIGestureRecognizerState) {
        guard let delegate = delegate else { return }

        if state == .began {
            delegate.setColor(imageView.image!.color(atPosition: position))
            delegate.showUnderFingerView()
            delegate.setAlphaHigh()
            drawDropperIndicator(position)
            setUnderFingerView(position, dropper: true)
        } else if state == .changed {
            let dropperColor = imageView.image!.color(atPosition: position)
            if let color = dropperColor {
                delegate.setColor(color)
            }
            drawDropperIndicator(position)
            setUnderFingerView(position, dropper: true)
        } else if state == .ended {
            delegate.setKeyboardState(.none)
            delegate.hideUnderFingerView()
            currentStroke = nil
            mergeCurrentStroke(false)
        }
    }
    
    fileprivate func curveTouch(_ position: CGPoint, state: UIGestureRecognizerState) {
        guard let delegate = delegate else { return }

        if state == .began {
            pts.removeAll()
            pts.append(position)
            finishStroke()
            delegate.showUnderFingerView()
            setUnderFingerView(position, dropper: false)
        } else if state == .changed {
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
            setUnderFingerView(position, dropper: false)
        } else if state == .ended {
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
            addToUndoStack(imageView.image)
            currentStroke = nil
            delegate.hideUnderFingerView()
        }
    }
    
    fileprivate func bullsEye(_ position: CGPoint, state: UIGestureRecognizerState) {
        guard let delegate = delegate else { return }
        
        if state == .began {
            drawDot(position)
            delegate.showUnderFingerView()
            setUnderFingerView(position, dropper: false)
        } else if state == .changed {
            drawDot(position)
            delegate.showUnderFingerView()
            setUnderFingerView(position, dropper: false)
        } else if state == .ended {
            addToUndoStack(imageView.image)
            currentStroke = nil
            mergeCurrentStroke(false)
            delegate.hideUnderFingerView()
        }
    }
    
    fileprivate func drawDot(_ position: CGPoint) {
        
        guard let delegate = delegate else { return }

        UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
        
        let color = delegate.getCurrentColor()
        
        UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: position.x, y: position.y))
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: position.x, y: position.y))
        
        UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
        UIGraphicsGetCurrentContext()?.setLineWidth(CGFloat(delegate.getCurrentBrushSize()) * resizeScale)
        UIGraphicsGetCurrentContext()?.setStrokeColor(red: color.coreImageColor!.red, green: color.coreImageColor!.green, blue: color.coreImageColor!.blue, alpha: 1.0)
        
        UIGraphicsGetCurrentContext()?.strokePath()
        UIGraphicsGetCurrentContext()?.flush()
        currentStroke = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    fileprivate func setUnderFingerView(_ position: CGPoint, dropper: Bool) {
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
    
    fileprivate func finishStroke() {
        
        guard let delegate = delegate else { return }
        
        if !pts.isEmpty {
            UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
            currentStroke?.draw(at: CGPoint.zero)
            
            let context = UIGraphicsGetCurrentContext()

            let color = delegate.getCurrentColor()
            
            if pts.count <= 2 {
                context?.move(to: CGPoint(x: pts.first!.x, y: pts.first!.y))
                context?.addLine(to: CGPoint(x: pts.last!.x, y: pts.last!.y))
            } else if pts.count == 3 {
                UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: pts[0].x, y: pts[0].y))
                context?.addQuadCurve(to: CGPoint(x: pts[1].x, y: pts[1].y), control: CGPoint(x: pts[2].x, y: pts[2].y))
            }
            else if pts.count == 4 {
                UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: pts[0].x, y: pts[0].y))
                context?.addQuadCurve(to: CGPoint(x: pts[1].x, y: pts[1].y), control: CGPoint(x: pts[3].x, y: pts[3].y))
            }
            
            UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
            UIGraphicsGetCurrentContext()?.setLineWidth(CGFloat(delegate.getCurrentBrushSize()) * resizeScale)
            UIGraphicsGetCurrentContext()?.setStrokeColor(red: color.coreImageColor!.red, green: color.coreImageColor!.green, blue: color.coreImageColor!.blue, alpha: 1.0)
            
            UIGraphicsGetCurrentContext()?.strokePath()
            UIGraphicsGetCurrentContext()?.flush()
            currentStroke = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    fileprivate func drawCurve() {
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

    fileprivate func drawDropperIndicator(_ point: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
        positionIndicator.draw(at: CGPoint(x: point.x - (positionIndicator.size.width / 2), y: point.y - (positionIndicator.size.height / 2)))
        UIGraphicsGetCurrentContext()?.strokePath()
        UIGraphicsGetCurrentContext()?.flush()
        currentStroke = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
  fileprivate func mergeCurrentStroke(_ alpha: Bool) {
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
    
    fileprivate func addToUndoStack(_ image: UIImage?) {
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
