//
//  CGContext+setColor.swift
//  Colorue
//
//  Created by Dylan Wight on 5/7/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

extension CGContext {
  func setStrokeColor (_ color: UIColor) {
    guard let coreColor = color.coreImageColor else { return }
    self.setStrokeColor(red: coreColor.red, green: coreColor.green, blue: coreColor.blue, alpha: 1.0)
  }
}
