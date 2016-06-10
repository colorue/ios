//
//  CanvasView.swift
//  ColorCouch
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class CanvasView: UIView, UIGestureRecognizerDelegate {
    private var delagate: CanvasDelagate
    private var lastPoint: CGPoint?
    private var currentStroke: UIImage?
    private var undoStack = [UIImage]()
    private var imageView = UIImageView()
    private let positionIndicator = UIImage(named: "PositionIndicator")!
    
    // The image is twice the size of the imageView
    private let resizeScale: CGFloat = 2.0
    private var actualSize = CGSize()
    
    private let prefs = NSUserDefaults.standardUserDefaults()
    
    
    // MARK: Initializer Methods
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init (frame: CGRect, delagate: CanvasDelagate, baseImage: UIImage?) {
        self.delagate = delagate
        super.init(frame : frame)
        
        actualSize = CGSize(width: frame.width * resizeScale, height: frame.height * resizeScale)

        displayCanvas(baseImage)
    }
    
    private func displayCanvas(baseImage: UIImage?) {
        if let base = baseImage {
            undoStack.append(base)
        } else {
            undoStack.append(UIImage.getImageWithColor(UIColor.whiteColor(), size: actualSize))
        }
        imageView.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        addSubview(imageView)
        
        let drag = UILongPressGestureRecognizer(target: self, action: #selector(CanvasView.handleDrag(_:)))
        drag.minimumPressDuration = 0.0
        drag.delegate = self
        addGestureRecognizer(drag)
        
        mergeCurrentStroke(false)
    }
    
    
    // MARK: Controll Methods
    
    @objc private func handleDrag(sender: UILongPressGestureRecognizer) {
        
        let actualPosition = CGPoint(x: sender.locationInView(imageView).x * resizeScale, y: sender.locationInView(imageView).y * resizeScale)
        mergeCurrentStroke(true)
        if delagate.getDropperActive() {
            dropperTouch(actualPosition, state: sender.state)
        } else {
            drawingTouch(actualPosition, state: sender.state)
        }
    }
    
    private func dropperTouch(position: CGPoint, state: UIGestureRecognizerState) {
        if state == .Began {
            let dropperColor = imageView.image!.colorAtPosition(position)
            if let color = dropperColor {
                delagate.setColor(color)
            }
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
            delagate.setDropperActive(false)
            delagate.hideUnderFingerView()
            currentStroke = nil
            mergeCurrentStroke(false) // clears the positionIndicator image
        }
    }
    
    private func drawingTouch(position: CGPoint, state: UIGestureRecognizerState) {
        if state == .Began {
            lastPoint = position
            drawLineTo(position)
            delagate.showUnderFingerView()
            setUnderFingerView(position, dropper: false)
        } else if state == .Changed {
            drawLineTo(position)
            lastPoint = position
            setUnderFingerView(position, dropper: false)
        } else if state == .Ended {
            addToUndoStack(imageView.image)
            currentStroke = nil
            delagate.hideUnderFingerView()
        }
    }
    
    private func setUnderFingerView(position: CGPoint, dropper: Bool) {
        let underFingerSize: CGSize // The underfinger view shows more of the drawing when the brush size is big
        
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
    
    private func drawLineTo(position: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(actualSize, false, 1.0)
        currentStroke?.drawAtPoint(CGPoint.zero)
        
        let color = delagate.getCurrentColor()
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(delagate.getCurrentBrushSize()) * resizeScale)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), color.coreImageColor!.red, color.coreImageColor!.green, color.coreImageColor!.blue, 1.0)
        
        if let lastP = lastPoint {
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastP.x, lastP.y)
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), position.x, position.y)
        }
        
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        CGContextFlush(UIGraphicsGetCurrentContext())
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
            currentStroke?.drawAtPoint(CGPoint.zero, blendMode: .Normal, alpha: delagate.getAlpha()!)
        } else {
            currentStroke?.drawAtPoint(CGPoint.zero, blendMode: .Normal, alpha: 1.0)
        }
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    private func addToUndoStack(image: UIImage?) {
        if let image = image {
            if undoStack.count <= 10 {
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
        currentStroke = (UIImage.getImageWithColor(whiteColor, size: actualSize))
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