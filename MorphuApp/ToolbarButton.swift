//
//  ToolbarButton.swift
//  Colorue
//
//  Created by Dylan Wight on 5/6/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation
import PureLayout

enum KeyboardToolState: Int {
  case none = 0
  case colorDropper = 1
  case paintBucket = 2
  case bullsEye = 3
}

protocol ToolbarButtonDelegate: class {
  func toolbarButtonTapped(_ toolbarButton: ToolbarButton)
}

class ToolbarButton: UIButton {
  var type: KeyboardToolState = .none

  let spinner = UIActivityIndicatorView()

  var iconImage: UIImage? {
    get {
      switch (type) {
      case .none:
        return nil
      case .colorDropper:
        return UIImage(systemName: "eyedropper")
      case .paintBucket:
        return R.image.paintBucket()
      case .bullsEye:
        return UIImage(systemName: "scope")
      }
    }
  }

  override var tintColor: UIColor! {
    didSet {
      spinner.color = tintColor
    }
  }

  weak var delegate: ToolbarButtonDelegate?

  convenience init(type: KeyboardToolState) {
    self.init()
    self.type = type
    layoutButton()
  }

  private func layoutButton () {
    print("layoutButton")
    self.addTarget(self, action: #selector(ToolbarButton.tapped(_:)), for: .touchUpInside)
    self.setImage(self.iconImage, for: .normal)
    self.setImage(nil, for: .focused)
    self.tintColor = .white
    self.showsTouchWhenHighlighted = true

    spinner.hidesWhenStopped = true
    spinner.color = .white
    self.addSubview(spinner)
    spinner.autoCenterInSuperview()
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

  @objc fileprivate func tapped(_ sender: UIButton) {
    Haptic.selectionChanged()
    delegate?.toolbarButtonTapped(self)
  }

  func startAnimating () {
    self.setImage(nil, for: .normal)
    spinner.startAnimating()
  }

  func stopAnimating () {
    self.setImage(iconImage, for: .normal)
    spinner.stopAnimating()
  }
}
