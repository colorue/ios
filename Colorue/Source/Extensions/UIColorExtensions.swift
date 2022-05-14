//
//  UIColorExtensions.swift
//  Colorue
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

extension UIColor {    
  var coreImageColor: CoreImage.CIColor? {
    return CoreImage.CIColor(color: self)  // The resulting Core Image color, or nil
  }

  static func blendColor(_ color1: UIColor, withColor color2: UIColor?, percentMix: CGFloat = 0.5) -> UIColor {
    guard let color2 = color2 else { return color1 }
    let c1 = color1.coreImageColor!
    let c2 = color2.coreImageColor!
    return UIColor(red: c1.red * (1 - percentMix) + c2.red * percentMix, green: c1.green * (1 - percentMix) + c2.green * percentMix, blue: c1.blue * (1 - percentMix) + c2.blue * percentMix, alpha: 1.0)
  }

  func getDarkness(alpha: CGFloat = 1.0) -> CGFloat{
    let equivalentColor = UIColor.blendColor(self, withColor: R.color.opacityCheck(), percentMix: (1.0 - alpha))
    let coreColor = equivalentColor.coreImageColor
    return coreColor!.red + coreColor!.green * 2.0 + coreColor!.blue
  }
}
