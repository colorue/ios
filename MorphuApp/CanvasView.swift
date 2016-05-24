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
    private var lastPoint: CGPoint?
    private var currentPoint: CGPoint?
    private var currentStroke: UIImage
    private var undoStack = [UIImage]()
    private var imageView = UIImageView()
    let prefs = NSUserDefaults.standardUserDefaults()
    
    let resizeScale: CGFloat = 2.0
    
    init (frame: CGRect, delagate: CanvasDelagate, baseImage: UIImage) {
        self.currentStroke = UIImage.getImageWithColor(UIColor.clearColor(), size: frame.size)
        self.delagate = delagate
        super.init(frame : frame)
        displayCanvas()
        self.undoStack.append(baseImage)
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
        
        let drag = UIPanGestureRecognizer(target: self, action: #selector(CanvasView.handleDrag(_:)))
        drag.delegate = self
        self.addGestureRecognizer(drag)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if self.delagate.getDropperActive() {
            self.delagate.setDropperActive(false)
            
            let dropperPoint = sender.locationInView(imageView)
            let dropperColor = imageView.image?.getPixelColor(CGPoint(x: dropperPoint.x * 2, y: dropperPoint.y * 2))
            
            self.delagate.setColor(dropperColor!)
            return
        }
        
        lastPoint = sender.locationInView(imageView)
        currentPoint = sender.locationInView(imageView)
        self.drawImage()
        self.mergeImages()
        self.shiftUndoStack()
        self.currentStroke = UIImage.getImageWithColor(UIColor.clearColor(), size: imageView.frame.size)
    }
    
    func handleDrag(sender: UIPanGestureRecognizer) {

        if (sender.numberOfTouches() > 1) { return }
        
        let underFingerSize = CGSize(width: 200, height: 200)
        self.mergeImages()
        
        if self.delagate.getDropperActive() {
            let dropperPoint = sender.locationInView(imageView)
            let dropperColor = imageView.image?.getPixelColor(CGPoint(x: dropperPoint.x * 2, y: dropperPoint.y * 2))
            
            self.delagate.setColor(dropperColor!)
            
            self.delagate.setUnderfingerView(imageView.image!.cropToSquare(CGPoint(x: dropperPoint.x * 2, y: dropperPoint.y * 2), cropSize: underFingerSize))
            
            if sender.state == .Ended {
                self.delagate.setDropperActive(false)
                self.delagate.hideUnderFingerView()
            }
            return
        }

        if sender.state == .Began {
            lastPoint = sender.locationOfTouch(0, inView: imageView)
            self.delagate.setUnderfingerView(imageView.image!.cropToSquare(CGPoint(x: lastPoint!.x * 2, y: lastPoint!.y * 2), cropSize: underFingerSize))
        }
        else if sender.state == .Changed {
            currentPoint = sender.locationOfTouch(0, inView: imageView)
            drawImage()
            lastPoint = currentPoint
            self.delagate.setUnderfingerView(imageView.image!.cropToSquare(CGPoint(x: currentPoint!.x * 2, y: currentPoint!.y * 2), cropSize: underFingerSize))
        }
        else if sender.state == .Ended {
            self.shiftUndoStack()
            self.currentStroke = UIImage.getImageWithColor(UIColor.clearColor(), size: imageView.frame.size)
            self.delagate.hideUnderFingerView()

        }
    }
    
    func shiftUndoStack() {
        if undoStack.count < 6 {
            undoStack.append(self.imageView.image!)
        } else {
            undoStack.removeAtIndex(0)
            undoStack.append(self.imageView.image!)
        }
    }
    
    func drawImage() {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale), false, 1.0)
        currentStroke.drawAtPoint(CGPoint.zero)
        
        let color = delagate.getCurrentColor()
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(delagate.getCurrentBrushSize()) * resizeScale)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), color.coreImageColor!.red, color.coreImageColor!.green, color.coreImageColor!.blue, UIScreen.mainScreen().scale)
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint!.x * resizeScale, lastPoint!.y * resizeScale)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint!.x * resizeScale, currentPoint!.y * resizeScale)
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        CGContextFlush(UIGraphicsGetCurrentContext())
        currentStroke = UIGraphicsGetImageFromCurrentImageContext()    // sets tempImage to line or dot drawn
        UIGraphicsEndImageContext()
    }
    
    func mergeImages() {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale), false, 1.0)

        undoStack.last!.drawAtPoint(CGPoint.zero)
        currentStroke.drawAtPoint(CGPoint.zero)
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func undo() {
        if undoStack.count > 1 {
            undoStack.popLast()
            mergeImages()
        }
    }
    
    func trash() {
        self.currentStroke = UIImage.getImageWithColor(UIColor.clearColor(), size: CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale))
        self.imageView.image = nil
        undoStack.append(UIImage.getImageWithColor(whiteColor, size: CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale)))
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

