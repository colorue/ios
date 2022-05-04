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
}
