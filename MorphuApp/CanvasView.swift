//
//  CanvasView.swift
//  Morphu
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class CanvasView: UIView, UIGestureRecognizerDelegate {
    private var delagate: CanvasDelagate
    
    private var points = [CGPoint]()
    
    private var currentStroke: UIImage?
    private var undoStack = [UIImage]()
    private var imageView = UIImageView()
    let prefs = NSUserDefaults.standardUserDefaults()
    
    var dataType: UnsafePointer<UInt8>?
    
    let resizeScale: CGFloat = 2.0
    
    init (frame: CGRect, delagate: CanvasDelagate, baseImage: UIImage) {
        self.undoStack.append(baseImage)
        self.currentStroke = UIImage()
        self.delagate = delagate
        super.init(frame : frame)
        displayCanvas()
        
        mergeImages()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func displayCanvas() {
        imageView.backgroundColor = UIColor.whiteColor()
        imageView.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CanvasView.handleTap(_:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        
        let drag = UILongPressGestureRecognizer(target: self, action: #selector(CanvasView.handleDrag(_:)))
        drag.minimumPressDuration = 0.01
        drag.delegate = self
        self.addGestureRecognizer(drag)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if self.delagate.getDropperActive() {
            self.delagate.setDropperActive(false)
            
//            let dropperPoint = sender.locationInView(imageView)
            
//            let dropperColor = self.getColorAtPoint(dropperPoint)
//            self.delagate.setColor(dropperColor)
            return
        }
        
//        lastPoint = sender.locationInView(imageView)
//        currentPoint = sender.locationInView(imageView)
        self.drawImage(sender.locationInView(imageView))
        self.mergeImages()
        self.shiftUndoStack()
        self.currentStroke = UIImage.getImageWithColor(UIColor.clearColor(), size: imageView.frame.size)
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
        
        self.mergeImages()
        
        if self.delagate.getDropperActive() {
            let dropperPoint = sender.locationInView(imageView)
//            let dropperColor = self.getColorAtPoint(dropperPoint)
//            self.delagate.setColor(dropperColor)
            
            self.delagate.setUnderfingerView(imageView.image!.cropToSquare(CGPoint(x: dropperPoint.x * resizeScale, y: dropperPoint.y * resizeScale), cropSize: underFingerSize))
            
            if sender.state == .Ended {
                self.delagate.setDropperActive(false)
                self.delagate.hideUnderFingerView()
            }
            return
        }

        if sender.state == .Began {
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale), false, 1.0)

//            lastPoint = sender.locationOfTouch(0, inView: imageView)
//            currentPoint = sender.locationInView(imageView)
            self.drawImage(sender.locationOfTouch(0, inView: imageView))
    
        
            
            self.delagate.showUnderFingerView()
            self.delagate.setUnderfingerView(imageView.image!.cropToSquare(CGPoint(x: sender.locationOfTouch(0, inView: imageView).x * resizeScale, y: sender.locationOfTouch(0, inView: imageView).y * resizeScale), cropSize: underFingerSize))
        }
        else if sender.state == .Changed {
//            currentPoint = sender.locationOfTouch(0, inView: imageView)
            drawImage(sender.locationOfTouch(0, inView: imageView))
//            lastPoint = currentPoint
            self.delagate.setUnderfingerView(imageView.image!.cropToSquare(CGPoint(x: sender.locationOfTouch(0, inView: imageView).x * resizeScale, y: sender.locationOfTouch(0, inView: imageView).y * resizeScale), cropSize: underFingerSize))
        }
        else if sender.state == .Ended {
            self.shiftUndoStack()
            self.currentStroke = nil
            self.delagate.hideUnderFingerView()
            UIGraphicsEndImageContext()
            points.removeAll()
        }
    }
    

    
    func drawImage(currentPoint: CGPoint) {
        
        if points.count < 4 {
            points.append(currentPoint)
        } else {
            points.removeAtIndex(0)
            points.append(currentPoint)
        }
        
        let color = delagate.getCurrentColor()
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(delagate.getCurrentBrushSize()) * resizeScale)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), color.coreImageColor!.red, color.coreImageColor!.green, color.coreImageColor!.blue, UIScreen.mainScreen().scale)
        
        CGContextSetLineJoin(UIGraphicsGetCurrentContext(), CGLineJoin.Round);

        if points.count == 4 {
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), points[0].x * resizeScale, points[0].y * resizeScale)
            CGContextAddCurveToPoint(UIGraphicsGetCurrentContext(), points[1].x * resizeScale, points[1].y * resizeScale, points[2].x * resizeScale, points[2].y * resizeScale, points[3].x * resizeScale, points[3].y * resizeScale)
            
            points.append(CGPoint(x: points[3].x * 2 - points[2].x, y: points[3].y * 2 - points[2].y))
            points.removeAtIndex(0)
            points.removeAtIndex(0)
            points.removeAtIndex(0)
        }

        
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        CGContextFlush(UIGraphicsGetCurrentContext())
        currentStroke = UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func shiftUndoStack() {
        if undoStack.count < 11 {
            undoStack.append(self.imageView.image!)
        } else {
            undoStack.removeAtIndex(0)
            undoStack.append(self.imageView.image!)
        }
    }
    
    func mergeImages() {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale), false, 1.0)

        undoStack.last?.drawAtPoint(CGPoint.zero)
        currentStroke?.drawAtPoint(CGPoint.zero)
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        let data = CGBitmapContextGetData(UIGraphicsGetCurrentContext())
        self.dataType = UnsafePointer<UInt8>(data)
        
        UIGraphicsEndImageContext()
    }
    
    func undo() {
        if undoStack.count > 1 {
            undoStack.popLast()
            mergeImages()
        }
    }
    
    func trash() {
        self.undoStack.append(UIImage.getImageWithColor(whiteColor, size: CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale)))
        mergeImages()
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