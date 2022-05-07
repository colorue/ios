//
//  ColorKeyboardView.swift
//  Colorue
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Foundation

protocol ColorKeyboardDelegate {
  func setColor(_ color: UIColor, secondary: UIColor, alpha: CGFloat)
}

let percentMix: CGFloat = 0.1

class ColorKeyboardView: UIStackView, UIGestureRecognizerDelegate {
  let currentColorView = UIView()
  let brushSizeSlider = BrushSizeSlider()
  let toolbarButtons = ToolbarButton.makeAll()

  var tool: ToolbarButton? {
    didSet {
      for button in toolbarButtons {
        button.isSelected = state == button.type
      }
    }
  }

  var state: KeyboardToolState {
    get {
      if let tool = tool {
        return tool.type
      } else {
        return .none
      }
    }
  }

  var opacity: CGFloat = 1.0 {
    didSet {
      currentColorView.alpha = opacity
      Store.setValue(opacity, forKey: Prefs.colorAlpha)
      updateButtonColor()
      delegate?.setColor(color, secondary: buttonColor, alpha: opacity)
    }
  }

  var color: UIColor = .white {
    didSet {
      currentColorView.backgroundColor = color
      Store.setValue(color.coreImageColor!.red, forKey: Prefs.colorRed)
      Store.setValue(color.coreImageColor!.green, forKey: Prefs.colorGreen)
      Store.setValue(color.coreImageColor!.blue, forKey: Prefs.colorBlue)
      updateButtonColor()
      delegate?.setColor(color, secondary: buttonColor, alpha: opacity)
    }
  }

  var buttonColor: UIColor {
    get {
      return color.getDarkness(alpha: alpha) < 1.87 ? .white : .black
    }
  }

  var brushSize: Float {
    get {
      return brushSizeSlider.size
    }
  }

  var delegate: ColorKeyboardDelegate?
  
  override init (frame: CGRect) {
    super.init(frame : frame)
    displayKeyboard()
    loadState()
  }

  required init(coder: NSCoder) {
    super.init(coder: coder)
    displayKeyboard()
    loadState()
  }

  private func displayKeyboard() {
    axis = .vertical
    distribution = .fill
    backgroundColor = UIColor(patternImage: R.image.clearPattern()!)

    let separatorU = UIView()
    separatorU.backgroundColor = Theme.divider
    separatorU.height(constant: 0.5)
    addArrangedSubview(separatorU)

    let toolbarWrapper = UIStackView()
    toolbarWrapper.distribution = .fillEqually
    toolbarWrapper.spacing = 16.0
    toolbarWrapper.height(constant: [(frame.width / 10), 80.0].min() ?? 0)
    addArrangedSubview(toolbarWrapper)

    toolbarWrapper.addSubview(currentColorView)
    currentColorView.autoPinEdgesToSuperviewEdges()

    let toolWrapperL = UIStackView()
    toolWrapperL.distribution = .fillEqually
    let toolWrapperR = UIStackView()
    toolWrapperR.distribution = .fillEqually

    toolbarWrapper.addArrangedSubview(toolWrapperL)
    toolbarWrapper.addArrangedSubview(brushSizeSlider)
    toolbarWrapper.addArrangedSubview(toolWrapperR)

    for tool in toolbarButtons {
      tool.delegate = self
      switch (tool.side) {
        case .left:  toolWrapperL.addArrangedSubview(tool)
        case .right: toolWrapperR.addArrangedSubview(tool)
        default: continue
      }
    }

    let colorButtonWrapper = UIStackView()
    colorButtonWrapper.distribution = .fillEqually
    addArrangedSubview(colorButtonWrapper)
    for (tag, color) in Theme.colors.enumerated() {
      let newButton = ColorButton(color: color, tag: tag)
      newButton.delegate = self
      colorButtonWrapper.addArrangedSubview(newButton)
    }
  }

  private func loadState () {
    if Store.bool(forKey: Prefs.saved) {
      let red = CGFloat(Store.float(forKey: Prefs.colorRed))
      let green = CGFloat(Store.float(forKey: Prefs.colorGreen))
      let blue = CGFloat(Store.float(forKey: Prefs.colorBlue))
      let alpha = CGFloat(Store.float(forKey: Prefs.colorAlpha))
      opacity = alpha
      color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
      brushSizeSlider.value = pow(Store.float(forKey: Prefs.brushSize), 1/sliderConstant)
    } else {
      brushSizeSlider.value = (brushSizeSlider.maximumValue + brushSizeSlider.minimumValue) / 2
      color = Theme.colors[Int(arc4random_uniform(8) + 1)]
      opacity = 1.0
    }
  }

  private func updateButtonColor() {
    brushSizeSlider.updateTint(color: color, alpha: opacity)
    for button in toolbarButtons {
      button.tintColor = buttonColor
    }
  }
}

extension ColorKeyboardView: ColorButtonDelegate {
  func colorButtonTapped(_ colorButton: ColorButton) {
    if (colorButton.isTransparent) {
      opacity = opacity * (1 - percentMix)
    } else {
      if (opacity == 0) {
        color = colorButton.color
      }
      opacity = opacity * (1 - percentMix) + percentMix
      color = UIColor.blendColor(color, withColor: colorButton.color, percentMix: percentMix)
    }
  }

  func colorButtonHeld(_ colorButton: ColorButton) {
    if (colorButton.isTransparent) {
      opacity = 0.0
      color = .white
    } else {
      opacity = 1.0
      color = colorButton.color
    }
  }
}

extension ColorKeyboardView: ToolbarButtonDelegate {
  func toolbarButtonTapped(_ toolbarButton: ToolbarButton) {
    if (state == toolbarButton.type) {
      tool = nil
    } else {
      tool = toolbarButton
    }
  }
}
