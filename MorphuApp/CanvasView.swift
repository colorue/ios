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
//    private var currentPoint: CGPoint?
    private var currentStroke: UIImage?
    private var undoStack = [UIImage]()
    private var imageView = UIImageView()
    
    private var actualSize = CGSize()
    
    private let prefs = NSUserDefaults.standardUserDefaults()
    
    private let positionIndicator = UIImage(named: "PositionIndicator")!
    private let resizeScale: CGFloat = 2.0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init (frame: CGRect, delagate: CanvasDelagate, baseImage: UIImage?) {
        self.delagate = delagate

        super.init(frame : frame)
        
        self.actualSize = CGSize(width: self.frame.width * resizeScale, height: self.frame.height * resizeScale)

        displayCanvas(baseImage)
    }
    
    private func displayCanvas(baseImage: UIImage?) {
        if let base = baseImage {
            self.undoStack.append(base)
        } else {
            self.undoStack.append(UIImage.getImageWithColor(UIColor.whiteColor(), size: self.actualSize))
        }
        imageView.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(imageView)
        
        let drag = UILongPressGestureRecognizer(target: self, action: #selector(CanvasView.handleDrag(_:)))
        drag.minimumPressDuration = 0.0
        drag.delegate = self
        self.addGestureRecognizer(drag)
        
        mergeImages(false)
    }
    
    @objc private func handleDrag(sender: UILongPressGestureRecognizer) {
        
        let actualPosition = CGPoint(x: sender.locationInView(imageView).x * resizeScale, y: sender.locationInView(imageView).y * resizeScale)
        self.mergeImages(true)
        
        if self.delagate.getDropperActive() {
            self.dropperTouch(actualPosition, state: sender.state)
        } else {
            self.colorTouch(actualPosition, state: sender.state)
        }
    }
    
    private func colorTouch(position: CGPoint, state: UIGestureRecognizerState) {
        if state == .Began {
            lastPoint = position
            self.drawImage(position)
            self.delagate.showUnderFingerView()
            self.setUnderFingerView(position, dropper: false)
        } else if state == .Changed {
            drawImage(position)
            lastPoint = position
            self.setUnderFingerView(position, dropper: false)
        } else if state == .Ended {
            self.addToUndoStack(self.imageView.image)
            self.currentStroke = nil
            self.delagate.hideUnderFingerView()
        }
    }
    
    private func dropperTouch(position: CGPoint, state: UIGestureRecognizerState) {
        if state == .Began {
            let dropperColor = self.imageView.image!.colorAtPosition(position)
            if let color = dropperColor {
                self.delagate.setColor(color)
            }
            self.delagate.showUnderFingerView()
            self.delagate.setAlphaHigh()
            self.drawDropperIndicator(position)
            self.setUnderFingerView(position, dropper: true)
        } else if state == .Changed {
            let dropperColor = self.imageView.image!.colorAtPosition(position)
            if let color = dropperColor {
                self.delagate.setColor(color)
            }
            self.drawDropperIndicator(position)
            self.setUnderFingerView(position, dropper: true)
        } else if state == .Ended {
            self.delagate.setDropperActive(false)
            self.delagate.hideUnderFingerView()
            self.currentStroke = nil
            self.mergeImages(false) // clears the positionIndicator image
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
            let brushSize = Double(self.delagate.getCurrentBrushSize())
        
            if (brushSize > ceilingSize) {
                underFingerSize = CGSize(width: maxUnderFinger, height: maxUnderFinger)
            } else if (brushSize < baseSize){
                underFingerSize = CGSize(width: minUnderFinger, height: minUnderFinger)
            } else {
                let underFinger = ((brushSize - baseSize) / ceilingSize) * (maxUnderFinger - minUnderFinger) + minUnderFinger
                underFingerSize = CGSize(width: underFinger, height: underFinger)
            }
        }
        
        self.delagate.setUnderfingerView(imageView.image!.cropToSquare(position, cropSize: underFingerSize))
    }
    
    // MARK: Drawing Methods
    
    private func drawImage(position: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale), false, 1.0)
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
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale), false, 1.0)
        positionIndicator.drawAtPoint(CGPoint(x: point.x - (positionIndicator.size.width / 2), y: point.y - (positionIndicator.size.height / 2)))
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        CGContextFlush(UIGraphicsGetCurrentContext())
        currentStroke = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
    // Displays the currentStroke on top of the last image in the undo stack
    private func mergeImages(alpha: Bool) {
        UIGraphicsBeginImageContextWithOptions(self.actualSize, false, 1.0)
        undoStack.last?.drawAtPoint(CGPoint.zero)
        if alpha {
            currentStroke?.drawAtPoint(CGPoint.zero, blendMode: .Normal, alpha: delagate.getAlpha()!)
        } else {
            currentStroke?.drawAtPoint(CGPoint.zero, blendMode: .Normal, alpha: 1.0)
        }
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
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
            mergeImages(false)
        }
    }
    
    func trash() {
        self.currentStroke = (UIImage.getImageWithColor(whiteColor, size: self.actualSize))
        self.mergeImages(false)
        self.addToUndoStack(self.imageView.image)
        self.currentStroke = nil
    }
    
    func getDrawing() -> UIImage {
        if let drawing = imageView.image {
            return drawing
        } else {
            return UIImage.getImageWithColor(UIColor.whiteColor(), size: self.actualSize)
        }
    }
}