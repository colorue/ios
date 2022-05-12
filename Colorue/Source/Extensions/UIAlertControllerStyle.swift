//
//  UIAlertControllerStyle.swift
//  Colorue
//
//  Created by Dylan Wight on 5/3/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

extension UIAlertController.Style {
  static var preferActionSheet: UIAlertController.Style {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return .alert
    } else {
      return .actionSheet
    }
  }
}
