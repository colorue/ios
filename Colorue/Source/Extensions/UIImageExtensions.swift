//
//  UIImageExtensions.swift
//  Colorue
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

extension UIImage {
  func cropToSquare(_ center: CGPoint, cropSize: CGSize) -> UIImage {
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
    let imageRef: CGImage = self.cgImage!.cropping(to: rect)!
    
    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(cgImage: imageRef)
    
    return image
  }
  
  static func getImageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
  }
  
  func toBase64() -> String {
    let imageData = self.pngData()!
    let base64String: String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions())
    return base64String
  }

  func scaleToFill(_ targetSize: CGSize?) -> UIImage {
    guard let targetSize = targetSize else { return self }
    let size = self.size

    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height

    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio < heightRatio) {
      newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
      newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }

    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: (targetSize.width - newSize.width) / 2.0, y: (targetSize.height - newSize.height) / 2.0, width: newSize.width, height: newSize.height)

    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
  }
  
  static func fromBase64(_ base64String: String) -> UIImage {
    var decodedImage = UIImage.getImageWithColor(UIColor.clear, size: CGSize(width: 1,height: 1))
    
    if let decodedData = Data(base64Encoded: base64String, options: NSData.Base64DecodingOptions()) {
      if let decodingImage = UIImage(data: decodedData) {
        decodedImage = decodingImage
      }
    }
    return decodedImage
  }
}

