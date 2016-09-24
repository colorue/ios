//
//  ImageBuffer.swift
//  PaintBucket
//
//  Created by Jack Flintermann on 3/15/16.
//  Copyright © 2016 jflinter. All rights reserved.
//

import CoreGraphics

class ImageBuffer {
    let context: CGContext
    let pixelBuffer: UnsafeMutablePointer<UInt32>
    let imageWidth: Int
    let imageHeight: Int
    
    init(image: CGImage) {
        self.imageWidth = Int(image.width)
        self.imageHeight = Int(image.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        self.context = CGContext(data: nil, width: imageWidth, height: imageHeight, bitsPerComponent: 8, bytesPerRow: imageWidth * 4, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)!
        self.context.draw(image, in: CGRect(x: 0, y: 0, width: CGFloat(imageWidth), height: CGFloat(imageHeight)))
        
        self.pixelBuffer = UnsafeMutablePointer<UInt32>(self.context.data)
    }
    
    func indexFrom(_ x: Int, _ y: Int) -> Int {
        return x + (self.imageWidth * y)
    }
    
    func differenceAtPoint(_ x: Int, _ y: Int, toPixel pixel: Pixel) -> Int {
        let index = indexFrom(x, y)
        let newPixel = self[index]
        return pixel.diff(newPixel)
    }
    
    func differenceAtIndex(_ index: Int, toPixel pixel: Pixel) -> Int {
        let newPixel = self[index]
        return pixel.diff(newPixel)
    }
    
    func scanline_replaceColor(_ colorPixel: Pixel, startingAtPoint startingPoint: (Int, Int), withColor replacementPixel: Pixel, tolerance: Int) {
        
        func testPixelAtPoint(_ x: Int, _ y: Int) -> Bool {
            return differenceAtPoint(x, y, toPixel: colorPixel) <= tolerance
        }
        
        let indices = NSMutableIndexSet(integer: indexFrom(startingPoint))
        while indices.count > 0 {
            let index = indices.first
            indices.remove(index)
            
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
                        indices.add(indexFrom(x, y + 1))
                    } else {
                        self[indexFrom(x, y + 1)] = replacementPixel
                    }
                }
                if y > 0 {
                    if testPixelAtPoint(x, y - 1) {
                        indices.add(indexFrom(x, y - 1))
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
            return Pixel(memory: pixelIndex.pointee)
        }
        set(pixel) {
            self.pixelBuffer[index] = pixel.uInt32Value
        }
    }
    
    var image: CGImage {
        return self.context.makeImage()!
    }
    
}
