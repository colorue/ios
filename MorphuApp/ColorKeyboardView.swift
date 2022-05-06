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
  func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

let percentMix: CGFloat = 0.1

class ColorKeyboardView: UIView, UIGestureRecognizerDelegate {
  let currentColorView = UIView()
  let brushSizeSlider = BrushSizeSlider()
  let dropperButton = ToolbarButton(type: .colorDropper)
  let paintBucketButton = ToolbarButton(type: .paintBucket)
  let bullsEyeButton = ToolbarButton(type: .bullsEye)

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

  var darkness: CGFloat {
    get {
      let equivalentColor = UIColor.blendColor(color, withColor: Theme.halfOpacityCheck, percentMix: (1.0 - opacity))
      let coreColor = equivalentColor.coreImageColor
      return coreColor!.red + coreColor!.green * 2.0 + coreColor!.blue
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
    
    backgroundColor = UIColor(patternImage: R.image.clearPattern()!)

    let colorButtonWrapper = UIView()
    colorButtonWrapper.frame = CGRect(x: 0, y: buttonSize, width: frame.width, height: frame.height - buttonSize)
    addSubview(colorButtonWrapper)
    for (tag, color) in Theme.colors.enumerated() {
      let newButton = ColorButton(color: color, tag: tag, isTransparent: tag == 0)
      newButton.frame = CGRect(x: frame.minX + CGFloat(tag) * selectorWidth, y: 0, width: selectorWidth, height: frame.height - buttonSize)
      newButton.delegate = self
      colorButtonWrapper.addSubview(newButton)
    }
    currentColorView.frame = CGRect(x: 0, y: 0, width: frame.width, height: buttonSize)
    addSubview(currentColorView)
    
    let toolbarWrapper = UIView()
    toolbarWrapper.frame = currentColorView.frame
    addSubview(toolbarWrapper)

    brushSizeSlider.center = CGPoint(x: frame.width/2.0, y: buttonSize/2.0)
    toolbarWrapper.addSubview(brushSizeSlider)

    paintBucketButton.delegate = self
    paintBucketButton.frame = CGRect(x: frame.maxX - (buttonSize * 1), y: 0, width: buttonSize, height: buttonSize)
    toolbarWrapper.addSubview(paintBucketButton)
    
    dropperButton.delegate = self
    dropperButton.frame = CGRect(x: (buttonSize), y: 0, width: buttonSize, height: buttonSize)
    toolbarWrapper.addSubview(dropperButton)
    
    bullsEyeButton.delegate = self
    bullsEyeButton.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
    toolbarWrapper.addSubview(bullsEyeButton)
    
    let separatorU = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 0.5))
    separatorU.backgroundColor = Theme.divider
    addSubview(separatorU)
    
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

  func updateButtonColor() {
    brushSizeSlider.updateColors(darkness: darkness)
    if (darkness < 1.87) {
      dropperButton.tintColor = .white
      paintBucketButton.tintColor = .white
      bullsEyeButton.tintColor = .white
    } else {
      dropperButton.tintColor = .black
      paintBucketButton.tintColor = .black
      bullsEyeButton.tintColor = .black
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
