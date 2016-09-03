//
//  CanvasView.swift
//  ColorCouch
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

protocol CanvasDelagate {
    func getCurrentColor() -> UIColor
    func getCurrentBrushSize() -> Float
    func getAlpha() -> CGFloat?
    func setAlphaHigh()
    func setUnderfingerView(underFingerImage: UIImage)
    func hideUnderFingerView()
    func showUnderFingerView()
    func setColor(color: UIColor?)
    func getKeyboardState() -> KeyboardToolState
    func setKeyboardState(state: KeyboardToolState)
    func startPaintBucketSpinner()
    func stopPaintBucketSpinner()
}

class CanvasView: UIView, UIGestureRecognizerDelegate {
    
    private var path: UIBezierPath = UIBezierPath()
    var pts = [CGPoint]()

    private var lastPoint: CGPoint?
    private var currentStroke: UIImage?
    private var undoStack = [UIImage]()
    private var imageView = UIImageView()
    private let positionIndicator = R.image.positionIndicator()!
    private let resizeScale: CGFloat = 2.0
    private var actualSize = CGSize()
    private let prefs = NSUserDefaults.standardUserDefaults()
    
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
    
    var delagate: CanvasDelagate?

    
    // MARK: Initializer Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        displayCanvas()
    }
    
    override init (frame: CGRect) {
        super.init(frame : frame)
        displayCanvas()
    }
    
    private func displayCanvas() {
        actualSize = CGSize(width: frame.width * resizeScale, height: frame.height * resizeScale)
        imageView.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        addSubview(imageView)
        
        let drag = UILongPressGestureRecognizer(target: self, action: #selector(CanvasView.handleDrag(_:)))
        drag.minimumPressDuration = 0.0
        drag.delegate = self
        addGestureRecognizer(drag)
    }
    
    
    // MARK: Controll Methods
    
    @objc private func handleDrag(sender: UILongPressGestureRecognizer) {
        guard let delagate = delagate else { return }
        
        let actualPosition = CGPoint(x: sender.locationInView(imageView).x * resizeScale, y: sender.locationInView(imageView).y * resizeScale)
        mergeCurrentStroke(true)
        
        switch (delagate.getKeyboardState()) {
        case .none:
            curveTouch(actualPosition, state: sender.state)
        case .colorDropper:
            dropperTouch(actualPosition, state: sender.state)
        case .paintBucket:
            paintBucket(actualPosition, state: sender.state)
        }
    }
    
    private func paintBucket(position: CGPoint, state: UIGestureRecognizerState) {
        guard let delagate = delagate else { return }
        
        if state == .Began {
            delagate.showUnderFingerView()
            drawDropperIndicator(position)
            setUnderFingerView(position, dropper: true)
        } else if state == .Changed {
            drawDropperIndicator(position)
            setUnderFingerView(position, dropper: true)
        } else if state == .Ended {
            currentStroke = nil
//            delagate.setKeyboardState(.none)
            delagate.startPaintBucketSpinner()
            delagate.hideUnderFingerView()

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let filledImage = self.undoStack.last?.pbk_imageByReplacingColorAt(Int(position.x), Int(position.y), withColor: delagate.getCurrentColor(), tolerance: 5)
                self.addToUndoStack(filledImage)
                dispatch_async(dispatch_get_main_queue()) {
                    self.mergeCurrentStroke(false)
                    delagate.stopPaintBucketSpinner()
                }
            }
        }
    }
    
    private func dropperTouch(position: CGPoint, state: UIGestureRecognizerState) {
        guard let delagate = delagate else { return }

        if state == .Began {
            delagate.setColor(imageView.image!.colorAtPosition(position))
            delagate.showUnderFingerView()
            delagate.setAlphaHigh()
            drawDropperIndicator(position)
            setUnderFingerView(position, dropper: true)
        } else if state == .Changed {
            let dropperColor = imageView.image!.colorAtPosition(position)
            if let color = dropperColor {
                delagate.setColor(color)
            }
            drawDropperIndicator(position)
            setUnderFingerView(position, dropper: true)
        } else if state == .Ended {
            delagate.setKeyboardState(.none)
            delagate.hideUnderFingerView()
            currentStroke = nil
            mergeCurrentStroke(false)
        }
    }
    
    private func curveTouch(position: CGPoint, state: UIGestureRecognizerState) {
        guard let delagate = delagate else { return }

        if state == .Began {
            pts.removeAll()
            pts.append(position)
            finishStroke()
            delagate.showUnderFingerView()
            setUnderFingerView(position, dropper: false)
        } else if state == .Changed {
            pts.append(position)
            if pts.count == 5 {
                pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0)
                path.moveToPoint(pts[0])
                path.addCurveToPoint(pts[3], controlPoint1: pts[1], controlPoint2: pts[2])
                self.drawCurve()
                pts[0] = pts[3]
                pts[1] = pts[4]
                pts.removeLast(3)
            }
            setUnderFingerView(position, dropper: false)
        } else if state == .Ended {
            pts.append(position)
            if pts.count >= 5 {
                pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0)
                path.moveToPoint(pts[0])
                path.addCurveToPoint(pts[3], controlPoint1: pts[1], controlPoint2: pts[2])
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
            delagate.hideUnderFingerView()
        }
    }
    
    private func setUnderFingerView(position: CGPoint, dropper: Bool) {
        guard let delagate = delagate else { return }

        let underFingerSize: CGSize
        
        let maxUnderFinger = 400.0
        let minUnderFinger = 200.0
        
        let ceilingSize = 80.0
        let baseSize = 10.0

        if dropper {
            underFingerSize = CGSize(width: minUnderFinger, height: minUnderFinger)
        } else {
            let brushSize = Double(delagate.getCurrentBrushSize())
        
            if (brushSize > ceilingSize) {
                underFingerSize = CGSize(width: maxUnderFinger, height: maxUnderFinger)
            } else if (brushSize < baseSize){
                underFingerSize = CGSize(width: minUnderFinger, height: minUnderFinger)
            } else {
                let underFinger = ((brushSize - baseSize) / ceilingSize) * (maxUnderFinger - minUnderFinger) + minUnderFinger
                underFingerSize = CGSize(width: underFinger, height: underFinger)
            }
        }
        delagate.setUnderfingerView(imageView.image!.cropToSquare(position, cropSize: underFingerSize))
    }
    
    
    // MARK: Drawing Methods
    
    private func finishStroke() {
        
        guard let delagate = delagate else { return }
        
        if !pts.isEmpty {
            UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
            currentStroke?.drawAtPoint(CGPoint.zero)

            let color = delagate.getCurrentColor()
            
            if pts.count <= 2 {
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), pts.first!.x, pts.first!.y)
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), pts.last!.x, pts.last!.y)
            } else if pts.count == 3 {
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), pts[0].x, pts[0].y)
                CGContextAddQuadCurveToPoint(UIGraphicsGetCurrentContext(), pts[1].x, pts[1].y, pts[2].x, pts[2].y)
            }
            else if pts.count == 4 {
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), pts[0].x, pts[0].y)
                CGContextAddQuadCurveToPoint(UIGraphicsGetCurrentContext(), pts[1].x, pts[1].y, pts[3].x, pts[3].y)
            }
            
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(delagate.getCurrentBrushSize()) * resizeScale)
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), color.coreImageColor!.red, color.coreImageColor!.green, color.coreImageColor!.blue, 1.0)
            
            CGContextStrokePath(UIGraphicsGetCurrentContext())
            CGContextFlush(UIGraphicsGetCurrentContext())
            currentStroke = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    private func drawCurve() {
        guard let delagate = delagate else { return }
        
        UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
        currentStroke?.drawAtPoint(CGPoint.zero)
        delagate.getCurrentColor().setStroke()
        path.lineWidth = CGFloat(delagate.getCurrentBrushSize()) * resizeScale
        path.lineCapStyle = CGLineCap.Round
        path.stroke()
        currentStroke = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    private func drawDropperIndicator(point: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
        positionIndicator.drawAtPoint(CGPoint(x: point.x - (positionIndicator.size.width / 2), y: point.y - (positionIndicator.size.height / 2)))
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        CGContextFlush(UIGraphicsGetCurrentContext())
        currentStroke = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
    private func mergeCurrentStroke(alpha: Bool) {
        UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
        undoStack.last?.drawAtPoint(CGPoint.zero)

        if alpha {
            currentStroke?.drawAtPoint(CGPoint.zero, blendMode: .Normal, alpha: delagate?.getAlpha() ?? 1.0)
        } else {
            currentStroke?.drawAtPoint(CGPoint.zero)
        }
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    private func addToUndoStack(image: UIImage?) {
        if let image = image {
            if undoStack.count <= 20 {
                undoStack.append(image)
            } else {
                undoStack.removeAtIndex(0)
                undoStack.append(image)
            }
        }
    }
    
    // MARK: External Methods
    
    func undo() {
        if undoStack.count > 1 {
            undoStack.popLast()
            mergeCurrentStroke(false)
        }
    }
    
    func trash() {
        currentStroke = (UIImage.getImageWithColor(UIColor.whiteColor(), size: actualSize))
        mergeCurrentStroke(false)
        addToUndoStack(imageView.image)
        currentStroke = nil
    }
    
    func getDrawing() -> UIImage {
        if let drawing = imageView.image {
            return drawing
        } else {
            return UIImage.getImageWithColor(UIColor.whiteColor(), size: actualSize)
        }
    }
}