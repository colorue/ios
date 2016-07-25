//
//  ImageBuffer.swift
//  PaintBucket
//
//  Created by Jack Flintermann on 3/15/16.
//  Copyright © 2016 jflinter. All rights reserved.
//

import CoreGraphics

class ImageBuffer {
    let context: CGContextRef
    let pixelBuffer: UnsafeMutablePointer<UInt32>
    let imageWidth: Int
    let imageHeight: Int
    
    init(image: CGImageRef) {
        self.imageWidth = Int(CGImageGetWidth(image))
        self.imageHeight = Int(CGImageGetHeight(image))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        self.context = CGBitmapContextCreate(nil, imageWidth, imageHeight, 8, imageWidth * 4, colorSpace, CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue)!
        CGContextDrawImage(self.context, CGRectMake(0, 0, CGFloat(imageWidth), CGFloat(imageHeight)), image)
        
        self.pixelBuffer = UnsafeMutablePointer<UInt32>(CGBitmapContextGetData(self.context))
    }
    
    func indexFrom(x: Int, _ y: Int) -> Int {
        return x + (self.imageWidth * y)
    }
    
    func differenceAtPoint(x: Int, _ y: Int, toPixel pixel: Pixel) -> Int {
        let index = indexFrom(x, y)
        let newPixel = self[index]
        return pixel.diff(newPixel)
    }
    
    func differenceAtIndex(index: Int, toPixel pixel: Pixel) -> Int {
        let newPixel = self[index]
        return pixel.diff(newPixel)
    }
    
    func scanline_replaceColor(colorPixel: Pixel, startingAtPoint startingPoint: (Int, Int), withColor replacementPixel: Pixel, tolerance: Int) {
        
        func testPixelAtPoint(x: Int, _ y: Int) -> Bool {
            return differenceAtPoint(x, y, toPixel: colorPixel) <= tolerance
        }
        
        let indices = NSMutableIndexSet(index: indexFrom(startingPoint))
        while indices.count > 0 {
            let index = indices.firstIndex
            indices.removeIndex(index)
            
            if differenceAtIndex(index, toPixel: colorPixel) > tolerance {
                continue
            }
            if differenceAtIndex(index, toPixel: replacementPixel) == 0 {
                continue
            }
            
            self[index] = replacementPixel
            
            let pointX = index % imageWidth
            let y = index / imageWidth
            
            var minX = pointX - 1
            var maxX = pointX + 1
            
            while minX >= 0 && testPixelAtPoint(minX, y) {
                let index = indexFrom(minX, y)
                self[index] = replacementPixel
                minX -= 1
            }
            self[indexFrom(minX, y)] = replacementPixel

            while maxX <= imageWidth && testPixelAtPoint(maxX, y) {
                let index = indexFrom(maxX, y)
                self[index] = replacementPixel
                maxX += 1
            }
            self[indexFrom(maxX, y)] = replacementPixel
            
            
            for x in ((minX + 1)...(maxX - 1)) {
                if y < imageHeight - 1 {
                    if testPixelAtPoint(x, y + 1) {
                        indices.addIndex(indexFrom(x, y + 1))
                    } else {
                        self[indexFrom(x, y + 1)] = replacementPixel
                    }
                }
                if y > 0 {
                    if testPixelAtPoint(x, y - 1) {
                        indices.addIndex(indexFrom(x, y - 1))
                    } else {
                        self[indexFrom(x, y - 1)] = replacementPixel
                    }
                }
            }
        }
    }
    
    subscript(index: Int) -> Pixel {
        get {
            let pixelIndex = pixelBuffer + index
            return Pixel(memory: pixelIndex.memory)
        }
        set(pixel) {
            self.pixelBuffer[index] = pixel.uInt32Value
        }
    }
    
    var image: CGImageRef {
        return CGBitmapContextCreateImage(self.context)!
    }
    
}
