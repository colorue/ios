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
        
        print("handleTap")
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale), false, 1.0)
        
        self.drawDot(sender.locationInView(imageView), color: delagate.getCurrentColor())

        UIGraphicsEndImageContext()

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
            self.drawImage(sender.locationOfTouch(0, inView: imageView))
            self.delagate.showUnderFingerView()
            self.delagate.setUnderfingerView(imageView.image!.cropToSquare(CGPoint(x: sender.locationOfTouch(0, inView: imageView).x * resizeScale, y: sender.locationOfTouch(0, inView: imageView).y * resizeScale), cropSize: underFingerSize))
        }
        else if sender.state == .Changed {
            drawImage(sender.locationOfTouch(0, inView: imageView))
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
        
        if points.count < 3 {
            points.append(currentPoint)
        } else {
            points.removeAtIndex(0)
            points.append(currentPoint)
        }
        

        if points.count == 3 {
            let color = delagate.getCurrentColor()
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(delagate.getCurrentBrushSize()) * resizeScale)
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), color.coreImageColor!.red, color.coreImageColor!.green, color.coreImageColor!.blue, UIScreen.mainScreen().scale)
            
            CGContextSetLineJoin(UIGraphicsGetCurrentContext(), CGLineJoin.Round)
            
            
            
            
            
            CGContextStrokePath(UIGraphicsGetCurrentContext())

            
            self.drawDot(a, color: greenColor)
            self.drawDot(b, color: redColor)
            self.drawDot(c, color: redColor)
            self.drawDot(d, color: greenColor)

            points.remove
            points.append(a)
            points.append(d)
            
            CGContextFlush(UIGraphicsGetCurrentContext())
            currentStroke = UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
    private func drawDot(dotPoint:CGPoint, color: UIColor) {
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(delagate.getCurrentBrushSize()) * resizeScale)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), color.coreImageColor!.red, color.coreImageColor!.green, color.coreImageColor!.blue, UIScreen.mainScreen().scale)
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), dotPoint.x * resizeScale, dotPoint.y * resizeScale)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), dotPoint.x * resizeScale, dotPoint.y * resizeScale)
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        CGContextFlush(UIGraphicsGetCurrentContext())
    }
    
    /*
    private func generateBiezerPoints(A: CGPoint, B: CGPoint, C: CGPoint) -> (CGPoint, CGPoint, CGPoint, CGPoint) {
        
        func getDelta(a: CGFloat, b: CGFloat, slope: CGFloat) -> CGFloat {
            return (b - a) / (2 + slope)
        }
        
        let P1: CGPoint
        let P2: CGPoint
        
        if (B.y == A.y) {
            print("(B.y == A.y)")
            P1 = CGPoint(x: B.x + (C.x - B.x)/2, y: B.y)
            P2 = CGPoint(x: B.x + (C.x - B.x)/2, y: C.y)
        } else if (B.x == A.x) {
            print("(B.x == A.x)")
            P1 = CGPoint(x: B.x, y: B.y + (C.y - B.y)/2)
            P2 = CGPoint(x: C.x, y: C.y + (C.x - B.x)/2)
        } else {
            print("else")

            let slope = (B.y - A.y) / (B.x - A.x)
            P1 = CGPoint(x: B.x + getDelta(B.x, b: C.x, slope: slope), y: B.y + getDelta(B.y, b: C.y, slope: (1/slope)))
            P2 = CGPoint(x: C.x - getDelta(B.x, b: C.x, slope: slope), y: C.y - getDelta(B.y, b: C.y, slope: (1/slope)))
        }
        
        return (B, P1, P2, C)
    }
 */
    
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
        
//        let data = CGBitmapContextGetData(UIGraphicsGetCurrentContext())
//        self.dataType = UnsafePointer<UInt8>(data)
        
        UIGraphicsEndImageContext()
    }
    
    func undo() {
        if undoStack.count > 1 {
            undoStack.popLast()
            mergeImages()
        }
    }
    
    func trash() {
        imageView.image = UIImage.getImageWithColor(whiteColor, size: CGSize(width: imageView.frame.size.width * resizeScale, height: imageView.frame.size.height * resizeScale))
        shiftUndoStack()
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