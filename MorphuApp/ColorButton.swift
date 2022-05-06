//
//  ColorButton.swift
//  Colorue
//
//  Created by Dylan Wight on 5/6/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import UIKit

protocol ColorButtonDelegate: class {
  func tapped(_ colorButton: ColorButton)
  func held(_ colorButton: ColorButton)
}

class ColorButton: UIButton {

  weak var delegate: ColorButtonDelegate?

  var color: UIColor {
    get {
      return backgroundColor ?? .white
    }
  }

  var isTransparent: Bool = false

  convenience init(color: UIColor, tag: Int, isTransparent: Bool = false) {
    self.init()
    self.backgroundColor = color
    self.tag = tag
    self.isTransparent = isTransparent

    self.addTarget(self, action: #selector(ColorButton.buttonTapped(_:)), for: UIControlEvents.touchUpInside)
    let tap = UILongPressGestureRecognizer(target: self, action: #selector(ColorButton.buttonHeld(_:)))
    tap.minimumPressDuration = 0.15
    tap.delegate = self
    self.addGestureRecognizer(tap)
  }

  @objc fileprivate func buttonHeld(_ sender: UITapGestureRecognizer) {
    Haptic.selectionChanged()
    delegate?.held(self)
  }

  @objc fileprivate func buttonTapped(_ sender: UIButton) {
    Haptic.selectionChanged()
    delegate?.tapped(self)
  }
}

extension ColorButton: UIGestureRecognizerDelegate {

}
