//
//  UIImage+PaintBucket.swift
//  PaintBucket
//
//  Created by Jack Flintermann on 3/13/16.
//  Copyright © 2016 jflinter. All rights reserved.
//

import UIKit

public extension UIImage {

  @objc public func pbk_imageByReplacingColorAt(_ x: Int, _ y: Int, withColor: UIColor, tolerance: Int) -> UIImage {

    guard x > 0, y > 0, x < Int(size.width), y < Int(size.height) else { return self }

    let point = CGPoint(x: x, y: y)
    let imageBuffer = ImageBuffer(image: self.cgImage!)
    let pixel = imageBuffer[imageBuffer.indexFrom(point: point)]
    let replacementPixel = Pixel(color: withColor)

    guard pixel.color != withColor else { return self }

    imageBuffer.scanline_replaceColor(pixel, startingAtPoint: point, withColor: replacementPixel, tolerance: tolerance)

    return UIImage(cgImage: imageBuffer.image, scale: self.scale, orientation: UIImage.Orientation.up)
  }
}
