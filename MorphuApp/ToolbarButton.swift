//
//  ToolbarButton.swift
//  Colorue
//
//  Created by Dylan Wight on 5/6/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

class ToolbarButton: UIButton {
  override init (frame: CGRect) {
    super.init(frame: frame)
    displayButton()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    displayButton()
  }


  private func displayButton() {
    setImage(UIImage(systemName: "eyedropper"), for: .normal)
    tintColor = .white
    showsTouchWhenHighlighted = true
  }

  override var isSelected: Bool {
    didSet {
      if isSelected {
        alpha = 0.4
      } else {
        alpha = 1.0
      }
    }
  }
}
