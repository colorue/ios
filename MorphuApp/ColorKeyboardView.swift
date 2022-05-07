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

class ColorKeyboardView: UIView, UIGestureRecognizerDelegate {
  let currentColorView = UIView()
  let brushSizeSlider = BrushSizeSlider()
  let dropperButton = ToolbarButton(type: .colorDropper)
  let paintBucketButton = ToolbarButton(type: .paintBucket)
  let bullsEyeButton = ToolbarButton(type: .bullsEye)
  let straightLineButton = ToolbarButton(type: .straightLine)
  var toolbarButtons = [ToolbarButton]()

  var tool: ToolbarButton? {
    didSet {
      dropperButton.isSelected = state == .colorDropper
      paintBucketButton.isSelected = state == .paintBucket
      bullsEyeButton.isSelected = state == .bullsEye
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
      delegate?.setColor(color, secondary: paintBucketButton.tintColor, alpha: opacity)
    }
  }

  var color: UIColor = .white {
    didSet {
      currentColorView.backgroundColor = color
      Store.setValue(color.coreImageColor!.red, forKey: Prefs.colorRed)
      Store.setValue(color.coreImageColor!.green, forKey: Prefs.colorGreen)
      Store.setValue(color.coreImageColor!.blue, forKey: Prefs.colorBlue)
      updateButtonColor()
      delegate?.setColor(color, secondary: paintBucketButton.tintColor, alpha: opacity)
    }
  }

  var brushSize: Float {
    get {
      return brushSizeSlider.size
    }
  }

  private var selectorWidth: CGFloat {
    get {
      return frame.width / CGFloat(Theme.colors.count)
    }
  }

  private var buttonSize: CGFloat {
    get {
      return  [(selectorWidth * 1.25), 80.0].min() ?? 0
    }
  }

  var delegate: ColorKeyboardDelegate?
  
  override init (frame: CGRect) {
    super.init(frame : frame)
    displayKeyboard()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    displayKeyboard()
  }
  
  private func displayKeyboard() {
    toolbarButtons = [dropperButton, paintBucketButton, bullsEyeButton, straightLineButton]
    backgroundColor = UIColor(patternImage: R.image.clearPattern()!)

    let colorButtonWrapper = UIStackView()
    colorButtonWrapper.frame = CGRect(x: 0, y: buttonSize, width: frame.width, height: frame.height - buttonSize)
    colorButtonWrapper.distribution = .fillEqually
    addSubview(colorButtonWrapper)
    for (tag, color) in Theme.colors.enumerated() {
      let newButton = ColorButton(color: color, tag: tag)
      newButton.delegate = self
      colorButtonWrapper.addArrangedSubview(newButton)
    }
    currentColorView.frame = CGRect(x: 0, y: 0, width: frame.width, height: buttonSize)
    addSubview(currentColorView)
    
    let toolbarWrapper = UIStackView()
    toolbarWrapper.distribution = .fillEqually
    toolbarWrapper.spacing = 16.0
    toolbarWrapper.frame = currentColorView.frame
    addSubview(toolbarWrapper)

    let toolWrapperL = UIStackView()
    toolWrapperL.distribution = .fillEqually
    let toolWrapperR = UIStackView()
    toolWrapperR.distribution = .fillEqually

    toolbarWrapper.addArrangedSubview(toolWrapperL)
    toolbarWrapper.addArrangedSubview(brushSizeSlider)
    toolbarWrapper.addArrangedSubview(toolWrapperR)

    straightLineButton.delegate = self
    toolWrapperL.addArrangedSubview(straightLineButton)
    
    dropperButton.delegate = self
    toolWrapperR.addArrangedSubview(dropperButton)

    paintBucketButton.delegate = self
    toolWrapperR.addArrangedSubview(paintBucketButton)
    
    bullsEyeButton.delegate = self
    toolWrapperR.addArrangedSubview(bullsEyeButton)
    
    let separatorU = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 0.5))
    separatorU.backgroundColor = Theme.divider
    addSubview(separatorU)
    loadState ()
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
      button.updateTint(color: color, alpha: opacity)
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
