//
//  UIImage+PaintBucket.swift
//  PaintBucket
//
//  Created by Jack Flintermann on 3/13/16.
//  Copyright © 2016 jflinter. All rights reserved.
//

import UIKit

public extension UIImage {
    
    @objc public func pbk_imageByReplacingColorAt(x: Int, _ y: Int, withColor: UIColor, tolerance: Int) -> UIImage {
        let point = (x, y)
        let imageBuffer = ImageBuffer(image: self.CGImage!)
        let pixel = imageBuffer[imageBuffer.indexFrom(point)]
        let replacementPixel = Pixel(color: withColor)
        imageBuffer.scanline_replaceColor(pixel, startingAtPoint: point, withColor: replacementPixel, tolerance: tolerance)
        
        return UIImage(CGImage: imageBuffer.image, scale: self.scale, orientation: UIImageOrientation.Up)
    }
}
