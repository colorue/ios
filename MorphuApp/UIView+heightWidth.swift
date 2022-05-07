//
//  UIView+heightWidth.swift
//  Colorue
//
//  Created by Dylan Wight on 5/7/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

extension UIView {
  func height(constant: CGFloat) {
    setConstraint(value: constant, attribute: .height)
  }

  func width(constant: CGFloat) {
    setConstraint(value: constant, attribute: .width)
  }

  private func removeConstraint(attribute: NSLayoutAttribute) {
    constraints.forEach {
      if $0.firstAttribute == attribute {
        removeConstraint($0)
      }
    }
  }

  private func setConstraint(value: CGFloat, attribute: NSLayoutAttribute) {
    removeConstraint(attribute: attribute)
    let constraint =
      NSLayoutConstraint(item: self,
                         attribute: attribute,
                         relatedBy: NSLayoutRelation.equal,
                         toItem: nil,
                         attribute: NSLayoutAttribute.notAnAttribute,
                         multiplier: 1,
                         constant: value)
    self.addConstraint(constraint)
  }
}
