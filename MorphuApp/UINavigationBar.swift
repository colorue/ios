//
//  UINavigationBar.swift
//  Colorue
//
//  Created by Dylan Wight on 5/3/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

extension UINavigationBar {
  func setBottomBorderColor(color: UIColor, height: CGFloat) {
    let bottomBorderRect = CGRect(x: 0, y: frame.height, width: frame.width, height: height)
    let bottomBorderView = UIView(frame: bottomBorderRect)
    bottomBorderView.backgroundColor = color
    addSubview(bottomBorderView)
  }
}
