//
//  UIImageExtensions.swift
//  Morphu
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(scale:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width*scale, height: size.height*scale)))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    func resizeToWidth(width:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    func cropToSquare(center: CGPoint, cropSize: CGSize) -> UIImage {
        var cropCenter = center
        // fixes cropping distorion on edges
        if (center.x < cropSize.width/2) {
            cropCenter.x = cropSize.width/2
        } else if (center.x > self.size.width - cropSize.width/2){
            cropCenter.x = self.size.width - cropSize.width/2
        }
        if (center.y < cropSize.height/2) {
            cropCenter.y = cropSize.height/2
        } else if (center.y > self.size.height - cropSize.height/2){
            cropCenter.y = self.size.height - cropSize.height/2
        }
        
        let posX = cropCenter.x - cropSize.width / 2
        let posY = cropCenter.y - cropSize.height / 2
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cropSize.width, height: cropSize.height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(self.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef)
        
        return image
    }
    
    static func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func toBase64() -> String {
        let imageData = UIImagePNGRepresentation(self)!
        let base64String: String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        return base64String
    }
    
    static func fromBase64(base64String: String) -> UIImage {
        var decodedImage = UIImage.getImageWithColor(UIColor.clearColor(), size: CGSize(width: 1,height: 1))
        
        if let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions()) {
            if let decodingImage = UIImage(data: decodedData) {
                decodedImage = decodingImage
            }
        }
        return decodedImage
    }
    
    
//    private func createARGBBitmapContext(inImage: CGImageRef) -> CGContext {
//        
//        //Get image width, height
//        let pixelsWide = CGImageGetWidth(inImage)
//        let pixelsHigh = CGImageGetHeight(inImage)
//        
//        // Declare the number of bytes per row. Each pixel in the bitmap in this
//        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
//        // alpha.
//        let bitmapBytesPerRow = Int(pixelsWide) * 4
////        let bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
//        
//        // Use the generic RGB color space.
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        
//        // Allocate memory for image data. This is the destination in memory
//        // where any drawing to the bitmap context will be rendered.
//        let bitmapData = UnsafeMutablePointer<UInt8>()
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
//        
//        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
//        // per component. Regardless of what the source image format is
//        // (CMYK, Grayscale, and so on) it will be converted over to the format
//        // specified here by CGBitmapContextCreate.
//        let context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
//        
//        return context!
//    }
    
    func sanitizePoint(point:CGPoint) {
        let inImage:CGImageRef = self.CGImage!
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        precondition(CGRectContainsPoint(rect, point), "CGPoint passed is not inside the rect of image.It will give wrong pixel and may crash.")
    }
    
    
    /*
     Get pixel color for a pixel in the image.
     */
//    func getPixelColorAtLocation(point:CGPoint)->UIColor? {
//        
//        self.sanitizePoint(point)
//        // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
//        let inImage:CGImageRef = self.CGImage!
//        let context = self.createARGBBitmapContext(inImage)
//        
//        let pixelsWide = CGImageGetWidth(inImage)
//        let pixelsHigh = CGImageGetHeight(inImage)
//        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
//        
//        //Clear the context
//        CGContextClearRect(context, rect)
//        
//        // Draw the image to the bitmap context. Once we draw, the memory
//        // allocated for the context for rendering will then contain the
//        // raw image data in the specified color space.
//        CGContextDrawImage(context, rect, inImage)
//        
//        // Now we can get a pointer to the image data associated with the bitmap
//        // context.
//        let data = CGBitmapContextGetData(context)
//        let dataType = UnsafePointer<UInt8>(data)
//        
//        let offset = 4*((Int(pixelsWide) * Int(point.y)) + Int(point.x))
//        let alphaValue = dataType[offset]
//        let redColor = dataType[offset+1]
//        let greenColor = dataType[offset+2]
//        let blueColor = dataType[offset+3]
//        
//        let redFloat = CGFloat(redColor)/255.0
//        let greenFloat = CGFloat(greenColor)/255.0
//        let blueFloat = CGFloat(blueColor)/255.0
//        let alphaFloat = CGFloat(alphaValue)/255.0
//        
//        return UIColor(red: redFloat, green: greenFloat, blue: blueFloat, alpha: alphaFloat)
//        
//        // When finished, release the context
//        // Free image data memory for the context
//    }
}

