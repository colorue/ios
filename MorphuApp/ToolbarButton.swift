//
//  ToolbarButton.swift
//  Colorue
//
//  Created by Dylan Wight on 5/6/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation
import PureLayout
import UIKit

enum KeyboardToolState: Int, CaseIterable {
  case none = 0
  case colorDropper = 1
  case paintBucket = 2
  case bullsEye = 3
  case straightLine = 4
  case curvedLine = 5
  case oval = 6
}

enum KeyboardToolSide: Int {
  case left = 0
  case right = 1
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
      case .straightLine:
        return UIImage(systemName: "pentagon")
      case .curvedLine:
        return UIImage(systemName: "point.topleft.down.curvedto.point.bottomright.up.fill")
      case .oval:
        return UIImage(systemName: "oval")
      }
    }
  }

  var side: KeyboardToolSide? {
    get {
      switch (type) {
      case .straightLine, .curvedLine, .oval:
        return .left
      case .colorDropper, .paintBucket, .bullsEye:
        return .right
      default:
        return nil
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

extension ToolbarButton {
  static func makeAll () -> [ToolbarButton] {
    return KeyboardToolState.allCases.map({ type in
      ToolbarButton(type: type)
    })
  }
}
