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

enum KeyboardToolState: Int {
  case none = 0
  case colorDropper = 1
  case paintBucket = 2
  case bullsEye = 3
}

class ColorKeyboardView: UIView, UIGestureRecognizerDelegate {
  let currentColorView = UIView()
  let brushSizeSlider = UISlider()
  let dropperButton = ToolbarButton()
  let paintBucketButton = ToolbarButton()
  let bullsEyeButton = ToolbarButton()
  let paintBucketSpinner = UIActivityIndicatorView()
  
  var feedbackGenerator: UISelectionFeedbackGenerator? = nil
  var pastStrokeSize:Float = 0.0
  
  fileprivate let prefs = UserDefaults.standard
  
  let sliderConstant:Float = 2.0
  
  var state: KeyboardToolState = .none {
    didSet {
      dropperButton.isSelected = state == .colorDropper
      paintBucketButton.isSelected = state == .paintBucket
      bullsEyeButton.isSelected = state == .bullsEye
    }
  }
  
  fileprivate var currentAlpha: CGFloat = 1.0 {
    didSet {
      currentColorView.alpha = currentAlpha
      prefs.setValue(currentAlpha, forKey: Prefs.colorAlpha)
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
  
  func displayKeyboard() {
    
    backgroundColor = UIColor(patternImage: R.image.clearPattern()!)
    
    let selectorWidth = frame.width/11
    let buttonSize = [(selectorWidth * 1.25), 80.0].min()!

    let colorButtonWrapper = UIView()
    colorButtonWrapper.frame = CGRect(x: 0, y: buttonSize, width: frame.width, height: frame.height - buttonSize)
    addSubview(colorButtonWrapper)
    for tag in 0...10 {
      colorButtonWrapper.addSubview(colorButton(withColor: Theme.colors[tag], tag: tag, selectorWidth: selectorWidth, buttonSize: buttonSize))
    }


    currentColorView.frame = CGRect(x: 0, y: 0, width: frame.width, height: buttonSize)
    addSubview(currentColorView)
    
    let toolbarWrapper = UIView()
    toolbarWrapper.frame = currentColorView.frame
    addSubview(toolbarWrapper)
    
    brushSizeSlider.minimumTrackTintColor = UIColor.lightGray
    brushSizeSlider.maximumTrackTintColor = UIColor.white
    brushSizeSlider.maximumValue = pow(100, 1/sliderConstant)
    brushSizeSlider.minimumValue = pow(1, 1/sliderConstant)
    brushSizeSlider.center = CGPoint(x: frame.width/2.0, y: buttonSize/2.0)
    brushSizeSlider.addTarget(self, action: #selector(ColorKeyboardView.sliderMoved(_:)), for: .valueChanged)
    brushSizeSlider.addTarget(self, action: #selector(ColorKeyboardView.sliderChanged(_:)), for: .touchUpInside)
    toolbarWrapper.addSubview(brushSizeSlider)
    

    paintBucketButton.setImage(R.image.paintBucket()!, for: .normal)
    paintBucketButton.tintColor = .white
    paintBucketButton.addTarget(self, action: #selector(ColorKeyboardView.paintBucket(_:)), for: .touchUpInside)
    paintBucketButton.frame = CGRect(x: frame.maxX - (buttonSize * 1), y: 0, width: buttonSize, height: buttonSize)
//    paintBucketButton.showsTouchWhenHighlighted = true
    paintBucketButton.layer.cornerRadius = buttonSize / 2.0
    toolbarWrapper.addSubview(paintBucketButton)
    
    paintBucketSpinner.hidesWhenStopped = true
    paintBucketSpinner.center = paintBucketButton.center
    paintBucketSpinner.color = .white
    toolbarWrapper.addSubview(paintBucketSpinner)
    
    dropperButton.setImage(UIImage(systemName: "eyedropper"), for: .normal)
    dropperButton.tintColor = .white
    dropperButton.addTarget(self, action: #selector(ColorKeyboardView.dropper(_:)), for: .touchUpInside)
    dropperButton.frame = CGRect(x: (buttonSize), y: 0, width: buttonSize, height: buttonSize)
//    dropperButton.showsTouchWhenHighlighted = true
    toolbarWrapper.addSubview(dropperButton)
    
    bullsEyeButton.setImage(UIImage(systemName: "scope"), for: .normal)

    bullsEyeButton.tintColor = .white
    bullsEyeButton.addTarget(self, action: #selector(ColorKeyboardView.bullsEye(_:)), for: .touchUpInside)
    bullsEyeButton.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
//    bullsEyeButton.showsTouchWhenHighlighted = true
    toolbarWrapper.addSubview(bullsEyeButton)
    
    let separatorU = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 0.5))
    separatorU.backgroundColor = Theme.divider
    addSubview(separatorU)
    
    if prefs.bool(forKey: Prefs.saved) {
      let red = CGFloat(prefs.float(forKey: Prefs.colorRed))
      let green = CGFloat(prefs.float(forKey: Prefs.colorGreen))
      let blue = CGFloat(prefs.float(forKey: Prefs.colorBlue))
      let alpha = CGFloat(prefs.float(forKey: Prefs.colorAlpha))
      
      currentAlpha = alpha
      setColor(UIColor(red: red, green: green, blue: blue, alpha: 1.0))
      brushSizeSlider.value = pow(prefs.float(forKey: Prefs.brushSize), 1/sliderConstant)
    } else {
      brushSizeSlider.value = (brushSizeSlider.maximumValue + brushSizeSlider.minimumValue) / 2
      setColor(Theme.colors[Int(arc4random_uniform(8) + 1)])
      currentAlpha = 1.0
    }

    updateButtonColor()
  }
  
  fileprivate func colorButton(withColor color: UIColor, tag: Int, selectorWidth: CGFloat, buttonSize: CGFloat) -> UIButton {
    let newButton = UIButton()
    newButton.backgroundColor = color
    newButton.tag = tag
    newButton.addTarget(self, action: #selector(ColorKeyboardView.buttonTapped(_:)), for: UIControlEvents.touchUpInside)
    newButton.frame = CGRect(x: frame.minX + CGFloat(tag) * selectorWidth, y: 0, width: selectorWidth, height: frame.height - buttonSize)
    
    let tap = UILongPressGestureRecognizer(target: self, action: #selector(ColorKeyboardView.buttonHeld(_:)))
    tap.minimumPressDuration = 0.15
    tap.delegate = self
    newButton.addGestureRecognizer(tap)
    
    return newButton
  }

  @objc fileprivate func dropper(_ sender: UIButton) {
    feedbackGenerator = UISelectionFeedbackGenerator()
    feedbackGenerator?.selectionChanged()
    feedbackGenerator = nil
    state = state == .colorDropper ? .none : .colorDropper
  }
  
  @objc fileprivate func paintBucket(_ sender: UIButton) {
    feedbackGenerator = UISelectionFeedbackGenerator()
    feedbackGenerator?.selectionChanged()
    feedbackGenerator = nil
    state = state == .paintBucket ? .none : .paintBucket
  }
  
  @objc fileprivate func bullsEye(_ sender: UIButton) {
    feedbackGenerator = UISelectionFeedbackGenerator()
    feedbackGenerator?.selectionChanged()
    feedbackGenerator = nil
    if (!prefs.bool(forKey: "bullsEyeHowTo")) {
      let dropperHowTo = UIAlertController(title: "Bull's Eye Tool", message: "Place a dot where you lift your finger" , preferredStyle: UIAlertControllerStyle.alert)
      dropperHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
      delegate?.present(dropperHowTo, animated: true, completion: nil)
      prefs.setValue(true, forKey: "bullsEyeHowTo")
    }
    state = state == .bullsEye ? .none : .bullsEye
  }
  
  @objc fileprivate func sliderMoved(_ sender: UISlider) {
    let newSize = Float(lroundf(sender.value))
    if newSize != pastStrokeSize {
      pastStrokeSize = newSize
      feedbackGenerator = feedbackGenerator ?? UISelectionFeedbackGenerator()
      feedbackGenerator?.selectionChanged()
      feedbackGenerator?.prepare()
    }
  }

  @objc fileprivate func sliderChanged(_ sender: UISlider) {
    let newSize = Float(lroundf(sender.value))
    sender.setValue(newSize, animated: true)
    feedbackGenerator = nil
    prefs.setValue(getCurrentBrushSize(), forKey: Prefs.brushSize)
  }
  
  @objc fileprivate func buttonHeld(_ sender: UITapGestureRecognizer) {
    feedbackGenerator = UISelectionFeedbackGenerator()
    feedbackGenerator?.selectionChanged()
    feedbackGenerator = nil
    if (sender.view!.tag == 0) {
      currentAlpha = 0.0
      setColor(.white)
    } else {
      currentAlpha = 1.0
      setColor(Theme.colors[sender.view!.tag])
    }
    updateButtonColor()
  }
  
  @objc fileprivate func buttonTapped(_ sender: UIButton) {
    feedbackGenerator = UISelectionFeedbackGenerator()
    feedbackGenerator?.selectionChanged()
    feedbackGenerator = nil
    let percentMix: CGFloat = 0.1
    
    if (sender.tag == 0) {
      currentAlpha = currentAlpha * (1 - percentMix)
    } else {
      if (currentAlpha == 0) {
        setColor(Theme.colors[sender.tag])
      }
      currentAlpha = currentAlpha * (1 - percentMix) + percentMix
      setColor(UIColor.blendColor(currentColorView.backgroundColor!, withColor: Theme.colors[sender.tag], percentMix: percentMix))
    }
    updateButtonColor()
  }
  
  func getCurrentColor() -> UIColor {
    return currentColorView.backgroundColor!
  }
  
  func getCurrentBrushSize() -> Float {
    return pow(brushSizeSlider.value, sliderConstant)
  }
  
  func getAlpha() -> CGFloat? {
    return currentAlpha
  }
  
  func setAlphaHigh() {
    currentAlpha = 1.0
  }
  
  func setColor(_ color: UIColor) {
    currentColorView.backgroundColor = color
    updateButtonColor()
    delegate?.setColor(color, secondary: paintBucketButton.tintColor, alpha: currentAlpha)
    prefs.setValue(color.coreImageColor!.red, forKey: Prefs.colorRed)
    prefs.setValue(color.coreImageColor!.green, forKey: Prefs.colorGreen)
    prefs.setValue(color.coreImageColor!.blue, forKey: Prefs.colorBlue)
  }
  
  func updateButtonColor() {
    let equivalentColor = UIColor.blendColor(currentColorView.backgroundColor!, withColor: Theme.halfOpacityCheck, percentMix: (1.0 - currentAlpha))
    let coreColor = equivalentColor.coreImageColor
    let colorDarkness = (coreColor!.red + coreColor!.green * 2.0 + coreColor!.blue)
    if (colorDarkness < 1.6) {
      brushSizeSlider.minimumTrackTintColor = UIColor.lightGray
      brushSizeSlider.maximumTrackTintColor = UIColor.white
    } else if colorDarkness < 2.67 {
      brushSizeSlider.minimumTrackTintColor = UIColor.black
      brushSizeSlider.maximumTrackTintColor = UIColor.white
    } else {
      brushSizeSlider.minimumTrackTintColor = UIColor.black
      brushSizeSlider.maximumTrackTintColor = UIColor.lightGray
    }
    
    if (colorDarkness < 1.87) {
      dropperButton.tintColor = .white
      paintBucketButton.tintColor = .white
      bullsEyeButton.tintColor = .white
      paintBucketSpinner.color = .white
    } else {
      dropperButton.tintColor = .black
      paintBucketButton.tintColor = .black
      bullsEyeButton.tintColor = .black
      paintBucketSpinner.color = .black
    }
  }
}


class ToolbarButton: UIButton {
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
