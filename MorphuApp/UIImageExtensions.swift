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
    
    func getPixelColor(pos: CGPoint) -> UIColor {
        if pos.x < 0 || pos.x > size.width || pos.y < 0 || pos.y > size.height {
            return whiteColor
        }
        
        print("X: \(pos.x), Y: \(pos.y), width: \(size.width), height: \(size.height)")
        
        let provider = CGImageGetDataProvider(self.CGImage)
        let providerData = CGDataProviderCopyData(provider)
        let data = CFDataGetBytePtr(providerData)
        
        let pixelData: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelData]) / 255.0
        let g = CGFloat(data[pixelData + 1]) / 255.0
        let b = CGFloat(data[pixelData + 2]) / 255.0
        let a = CGFloat(data[pixelData + 3]) / 255.0
        
        // Flipped red and blue for some reason
        return UIColor(red: b, green: g, blue: r, alpha: a)
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
}

