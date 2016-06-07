//
//  CanvasView.swift
//  Morphu
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright Â© 2016 Dylan Wight. All rights reserved.
//

import UIKit

class CanvasView: UIView, UIGestureRecognizerDelegate {
    private var delagate: CanvasDelagate
    private var lastPoint: CGPoint?
    private var currentPoint: CGPoint?
    private var currentStroke: UIImage?
    private var undoStack = [UIImage]()
    private var imageView = UIImageView()
    let prefs = NSUserDefaults.standardUserDefaults()
    
    let positionIndicator = UIImage(named: "PositionIndicator")!

    
    var dataType: UnsafePointer<UInt8>?
    
    let resizeScale: CGFloat = 2.0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init (frame: CGRect, delagate: CanvasDelagate, baseImage: UIImage?) {
        self.delagate = delagate
        super.init(frame : frame)
        displayCanvas(baseImage)
    }
    
    func displayCanvas(baseImage: UIImage?) {
        
        if let base = baseImage {
            self.undoStack.append(base)
        } else {
            self.undoStack.append(UIImage.getImageWithColor(UIColor.whiteColor(), size: CGSize(width: self.frame.width * resizeScale, height: self.frame.height * resizeScale)))
        }
//        imageView.backgroundColor = UIColor.whiteColor()
        imageView.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CanvasView.handleTap(_:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        
        let drag = UILongPressGestureRecognizer(target: self, action: #selector(CanvasView.handleDrag(_:)))
        drag.minimumPressDuration = 0.01
        drag.delegate = self
        self.addGestureRecognizer(drag)
        
        mergeImages(false)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if self.delagate.getDropperActive() {
            self.delagate.setDropperActive(false)
            
            return
        }
        
        print("handleTap")
        
        lastPoint = sender.locationInView(imageView)
        currentPoint = sender.locationInView(imageView)
        self.drawImage()
        self.mergeImages(true)
        self.shiftUndoStack()
        self.currentStroke = nil
    }
    
    func handleDrag(sender: UILongPressGestureRecognizer) {
        
        if (sender.numberOfTouches() > 1) { return }
        
        let brushSize = Double(self.delagate.getCurrentBrushSize())
        let underFingerSize: CGSize
        
        let maxUnderFinger = 400.0
        let minUnderFinger = 200.0
        
        let ceilingSize = 80.0
        let baseSize = 10.0
        
        if (brushSize > ceilingSize) {
            underFingerSize = CGSize(width: maxUnderFinger, height: maxUnderFinger)
        } else if (brushSize < baseSize){
            underFingerSize = CGSize(width: minUnderFinger, height: minUnderFinger)
        } else {
            let underFinger = ((brushSize - baseSize) / ceilingSize) * (maxUnderFinger - minUnderFinger) + minUnderFinger
            underFingerSize = CGSize(width: underFinger, height: underFinger)
        }
        
        self.mergeImages(true)
        
        if self.delagate.getDropperActive() {
            
            let dropperPoint = CGPoint(x: sender.locationInView(imageView).x * resizeScale, y: sender.locationInView(imageView).y * resizeScale)
           
            self.delagate.setUnderfingerView(imageView.image!.cropToSquare(dropperPoint, cropSize: CGSize(width: minUnderFinger, height: minUnderFinger)))
            
            if sender.state == .Began {
                let dropperColor = self.imageView.image!.colorAtPosition(dropperPoint)
                if let color = dropperColor {
                    self.delagate.setColor(color)
                }
                self.delagate.showUnderFingerView()
                self.delagate.setAlphaHigh()
                currentPoint = sender.locationInView(imageView)
                self.drawPositionIndicator(dropperPoint)
            } else if sender.state == .Changed {
                let dropperColor = self.imageView.image!.colorAtPosition(dropperPoint)
                if let color = dropperColor {
                    self.delagate.setColor(color)
                }
                currentPoint = sender.locationInView(imageView)
                self.drawPositionIndicator(dropperPoint)
            } else if sender.state == .Ended {
                self.delagate.setDropperActive(false)
                self.delagate.hideUnderFingerView()
                self.currentStroke = nil
                self.mergeImages(false)
            }
        } else {
        
            if sender.state == .Began {
                lastPoint = sender.locationOfTouch(0, inView: imageView)
                currentPoint = sender.locationInView(imageView)
                self.drawImage()
                self.delagate.showUnderFingerView()
                self.delagate.setUnderfingerView(imageView.image!.cropToSquare(CGPoint(x: lastPoint!.x * resizeScale, y: lastPoint!.y * resizeScale), cropSize: underFingerSize))
            } else if sender.state == .Changed {
                currentPoint = sender.locationOfTouch(0, inView: imageView)
                drawImage()
                lastPoint = currentPoint
                self.delagate.setUnderfingerView(imageView.image!.cropToSquare(CGPoint(x: currentPoint!.x * resizeScale, y: currentPoint!.y * resizeScale), cropSize: underFingerSize))
            } else if sender.state == .Ended {
                self.shiftUndoStack()
                self.currentStroke = nil
                self.delagate.hideUnderFingerView()
            }
        }
    }
    
    func trash() {
        self.currentStroke = UIImage.getImageWithColor(whiteColor, size: CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale))
        self.mergeImages(false)
        self.shiftUndoStack()
        self.currentStroke = nil
    }
    
    private func drawPositionIndicator(point: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale), false, 1.0)
        positionIndicator.drawAtPoint(CGPoint(x: point.x - (positionIndicator.size.width / 2), y: point.y - (positionIndicator.size.height / 2)))
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        CGContextFlush(UIGraphicsGetCurrentContext())
        currentStroke = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
    private func drawImage() {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale), false, 1.0)
        currentStroke?.drawAtPoint(CGPoint.zero)
        
        let color = delagate.getCurrentColor()
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(delagate.getCurrentBrushSize()) * resizeScale)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), color.coreImageColor!.red, color.coreImageColor!.green, color.coreImageColor!.blue, 1.0)
        
        if let lastP = lastPoint {
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastP.x * resizeScale, lastP.y * resizeScale)
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint!.x * resizeScale, currentPoint!.y * resizeScale)
        }
        
        CGContextSetLineJoin(UIGraphicsGetCurrentContext(), CGLineJoin.Round);
        CGContextSetMiterLimit(UIGraphicsGetCurrentContext(), 10.0);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        CGContextFlush(UIGraphicsGetCurrentContext())
        currentStroke = UIGraphicsGetImageFromCurrentImageContext()    // sets tempImage to line or dot drawn
        UIGraphicsEndImageContext()
        
    }
    
    func shiftUndoStack() {
        if undoStack.count < 11 {
            undoStack.append(self.imageView.image!)
        } else {
            undoStack.removeAtIndex(0)
            undoStack.append(self.imageView.image!)
        }
    }
    
    func mergeImages(alpha: Bool) {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale), false, 1.0)
        
        undoStack.last?.drawAtPoint(CGPoint.zero)
        
        if alpha {
            currentStroke?.drawAtPoint(CGPoint.zero, blendMode: .Normal, alpha: delagate.getAlpha()!)
        } else {
            currentStroke?.drawAtPoint(CGPoint.zero, blendMode: .Normal, alpha: 1.0)
        }
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    func undo() {
        if undoStack.count > 1 {
            undoStack.popLast()
            mergeImages(false)
        }
    }
    
    func dropper() {
        self.delagate.setDropperActive(true)
    }
    
    func getDrawing() -> UIImage {
        if let drawing = imageView.image {
            return drawing
        } else {
            return UIImage.getImageWithColor(UIColor.whiteColor(), size: self.frame.size)
        }
    }
}

//