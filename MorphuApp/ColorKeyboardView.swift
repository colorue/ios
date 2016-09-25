//
//  ColorKeyboardView.swift
//  Colorue
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Foundation

protocol ColorKeyboardDelagate {
    func undo()
    func trash()
    func switchAlphaHowTo()
    func presentViewController(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
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
    let undoButton = UIButton()
    let trashButton = UIButton()
    let dropperButton = UIButton()
    let paintBucketButton = UIButton()
    let bullsEyeButton = UIButton()
    let paintBucketSpinner = UIActivityIndicatorView()
    
    let eraserButton = UIButton()
    let alphaButton = UIButton()
    let progressBar = UIProgressView()
    fileprivate let prefs = UserDefaults.standard
    
    let sliderConstant:Float = 2.0
    
    var state: KeyboardToolState = .none {
        didSet {
            dropperButton.isSelected = state == .colorDropper
            paintBucketButton.isSelected = state == .paintBucket
            bullsEyeButton.isSelected = state == .bullsEye
        }
    }
    
    fileprivate var currentAlpha = AlphaType.high {
        didSet {
            switch(currentAlpha) {
            case .high:
                alphaButton.setImage(R.image.alphaHigh(), for: UIControlState())
            case .medium:
                alphaButton.setImage(R.image.alphaMid(), for: UIControlState())
            case .low:
                alphaButton.setImage(R.image.alphaLow(), for: UIControlState())
            }
        }
    }
    
    enum AlphaType: CGFloat {
        case high = 1.0
        case medium = 0.7
        case low = 0.3
    }

    var delagate: ColorKeyboardDelagate?
    
    override init (frame: CGRect) {
        super.init(frame : frame)
        displayKeyboard()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        displayKeyboard()
    }
    
    func displayKeyboard() {
        let selectorWidth = frame.width/10
        
        for tag in 0...9 {
            addSubview(colorButton(withColor: colors[tag], tag: tag, selectorWidth: selectorWidth))
        }
        
        currentColorView.frame = CGRect(x: 0, y: 0, width: frame.width, height: selectorWidth)
        addSubview(currentColorView)
        
        
        brushSizeSlider.minimumTrackTintColor = UIColor.lightGray
        brushSizeSlider.maximumTrackTintColor = UIColor.white
        brushSizeSlider.maximumValue = pow(100, 1/sliderConstant)
        brushSizeSlider.minimumValue = pow(1, 1/sliderConstant)
        
        brushSizeSlider.center = CGPoint(x: frame.width/2.0, y: selectorWidth/2.0)
        
        brushSizeSlider.addTarget(self, action: #selector(ColorKeyboardView.sliderChanged(_:)), for: .touchUpInside)
        addSubview(brushSizeSlider)
        
        let buttonSize = selectorWidth
        
        undoButton.setImage(R.image.undoIcon(), for: UIControlState())
        undoButton.tintColor = .white
        undoButton.addTarget(self, action: #selector(ColorKeyboardView.undo(_:)), for: .touchUpInside)
        undoButton.frame = CGRect(x: frame.minX + buttonSize, y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        undoButton.showsTouchWhenHighlighted = true
        addSubview(undoButton)
        
        trashButton.setImage(R.image.trashIcon(), for: UIControlState())
        trashButton.tintColor = .white
        trashButton.addTarget(self, action: #selector(ColorKeyboardView.trash(_:)), for: .touchUpInside)
        trashButton.frame = CGRect(x: frame.minX, y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        trashButton.showsTouchWhenHighlighted = true
        addSubview(trashButton)
        
        paintBucketButton.setImage(R.image.paintBucket(), for: UIControlState())
        paintBucketButton.setImage(R.image.paintBucketActive(), for: .selected)
        paintBucketButton.tintColor = .white
        paintBucketButton.addTarget(self, action: #selector(ColorKeyboardView.paintBucket(_:)), for: .touchUpInside)
        paintBucketButton.frame = CGRect(x: frame.maxX - (buttonSize * 1), y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        paintBucketButton.showsTouchWhenHighlighted = true
        addSubview(paintBucketButton)
        
        paintBucketSpinner.hidesWhenStopped = true
        paintBucketSpinner.center = paintBucketButton.center
        paintBucketSpinner.color = .white
        addSubview(paintBucketSpinner)
        
        dropperButton.setImage(R.image.dropper(), for: UIControlState())
        dropperButton.setImage(R.image.dropperActive(), for: .selected)
        dropperButton.tintColor = .white
        dropperButton.addTarget(self, action: #selector(ColorKeyboardView.dropper(_:)), for: .touchUpInside)
        dropperButton.frame = CGRect(x: frame.maxX - (buttonSize * 2), y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        dropperButton.showsTouchWhenHighlighted = true
        addSubview(dropperButton)
        
        bullsEyeButton.setImage(R.image.bullsEye(), for: UIControlState())
        bullsEyeButton.setImage(R.image.bullsEyeActive(), for: .selected)
        bullsEyeButton.tintColor = .white
        bullsEyeButton.addTarget(self, action: #selector(ColorKeyboardView.bullsEye(_:)), for: .touchUpInside)
        bullsEyeButton.frame = CGRect(x: frame.maxX - (buttonSize * 3), y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        bullsEyeButton.showsTouchWhenHighlighted = true
        addSubview(bullsEyeButton)
        
        alphaButton.tintColor = .white
        alphaButton.addTarget(self, action: #selector(ColorKeyboardView.switchAlpha(_:)), for: .touchUpInside)
        alphaButton.frame = CGRect(x: frame.minX + (buttonSize * 2), y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        alphaButton.showsTouchWhenHighlighted = true
        addSubview(alphaButton)

        let separatorU = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 0.5))
        separatorU.backgroundColor = UIColor.lightGray
        addSubview(separatorU)
        
        progressBar.frame = CGRect(x: 0, y: 0, width: frame.width/2, height: 0)
        progressBar.center = currentColorView.center
        progressBar.progress = 0.0
        progressBar.isHidden = true
        addSubview(progressBar)
        
        if prefs.bool(forKey: Prefs.saved) {
            let red = CGFloat(prefs.float(forKey: Prefs.colorRed))
            let green = CGFloat(prefs.float(forKey: Prefs.colorGreen))
            let blue = CGFloat(prefs.float(forKey: Prefs.colorBlue))
            let alpha = CGFloat(prefs.float(forKey: Prefs.colorAlpha))
            
            switch (round(1000 * alpha) / 1000) {
            case AlphaType.low.rawValue:
                currentAlpha = .low
            case AlphaType.medium.rawValue:
                currentAlpha = .medium
            default:
                currentAlpha = .high
            }

            currentColorView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            brushSizeSlider.value = pow(prefs.float(forKey: Prefs.brushSize), 1/sliderConstant)
        } else {
            brushSizeSlider.value = (brushSizeSlider.maximumValue + brushSizeSlider.minimumValue) / 2
            currentColorView.backgroundColor = colors[Int(arc4random_uniform(8) + 1)]
        }
        
        updateButtonColor()
    }
    
    fileprivate func colorButton(withColor color:UIColor, tag: Int, selectorWidth: CGFloat) -> UIButton {
        let newButton = UIButton()
        newButton.backgroundColor = color
        newButton.tag = tag
        newButton.addTarget(self, action: #selector(ColorKeyboardView.buttonTapped(_:)), for: UIControlEvents.touchUpInside)
        newButton.frame = CGRect(x: frame.minX + CGFloat(tag) * selectorWidth, y: selectorWidth, width: selectorWidth, height: frame.height - selectorWidth)
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(ColorKeyboardView.buttonHeld(_:)))
        tap.minimumPressDuration = 0.15
        tap.delegate = self
        newButton.addGestureRecognizer(tap)
        
        return newButton
    }
    
    @objc fileprivate func undo(_ sender: UIButton) {
        delagate?.undo()
    }
    
    @objc fileprivate func trash(_ sender: UIButton) {
        delagate?.trash()
        state = .none
    }
    
    @objc fileprivate func dropper(_ sender: UIButton) {
        state = state == .colorDropper ? .none : .colorDropper
    }
    
    @objc fileprivate func paintBucket(_ sender: UIButton) {
        state = state == .paintBucket ? .none : .paintBucket
    }
    
    @objc fileprivate func bullsEye(_ sender: UIButton) {
        
        if (!prefs.bool(forKey: "bullsEyeHowTo")) {
            let dropperHowTo = UIAlertController(title: "Bull's Eye Tool", message: "Place a dot where you lift your finger" , preferredStyle: UIAlertControllerStyle.alert)
            dropperHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            delagate?.presentViewController(dropperHowTo, animated: true, completion: nil)
            prefs.setValue(true, forKey: "bullsEyeHowTo")
        }
        state = state == .bullsEye ? .none : .bullsEye
    }
    
    @objc fileprivate func sliderChanged(_ sender: UISlider) {
        sender.setValue(Float(lroundf(sender.value)), animated: true)
    }
    
    @objc fileprivate func switchAlpha(_ sender: UIButton) {
        switch(currentAlpha) {
        case .high:
            currentAlpha = .medium
        case .medium:
            currentAlpha = .low
        case .low:
            currentAlpha = .high
        }
        delagate?.switchAlphaHowTo()
    }
    
    @objc fileprivate func buttonHeld(_ sender: UITapGestureRecognizer) {
        currentColorView.backgroundColor = colors[sender.view!.tag]
        updateButtonColor()
    }
    
    @objc fileprivate func buttonTapped(_ sender: UIButton) {
        let percentMix: CGFloat = 0.1
        currentColorView.backgroundColor = blendColor(currentColorView.backgroundColor!, withColor: colors[sender.tag], percentMix: percentMix)

        updateButtonColor()
    }
    
    fileprivate func blendColor(_ color1: UIColor, withColor color2: UIColor, percentMix: CGFloat) -> UIColor {
        let c1 = color1.coreImageColor!
        let c2 = color2.coreImageColor!
        return UIColor(red: c1.red * (1 - percentMix) + c2.red * percentMix, green: c1.green * (1 - percentMix) + c2.green * percentMix, blue: c1.blue * (1 - percentMix) + c2.blue * percentMix, alpha: 1.0)
    }
    
    func getCurrentColor() -> UIColor {
        return currentColorView.backgroundColor!
    }
    
    func getCurrentBrushSize() -> Float {
        return  pow(brushSizeSlider.value, sliderConstant)
    }
    
    func getAlpha() -> CGFloat? {
        return currentAlpha.rawValue
    }
    
    func setAlphaHigh() {
        currentAlpha = .high
    }
    
    func setColor(_ color: UIColor) {
        setCurrentColor(color, animationTime: 0.5)
    }
    
    fileprivate func setCurrentColor(_ color: UIColor, animationTime: Double) {
        UIView.animate(withDuration: animationTime,delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.currentColorView.backgroundColor = color
            }, completion: nil)
    }
    
    func updateButtonColor() {
        let coreColor = currentColorView.backgroundColor?.coreImageColor!
        let colorDarkness = coreColor!.red + coreColor!.green * 2.0 + coreColor!.blue
        
        if (colorDarkness < 1.6) {
            brushSizeSlider.minimumTrackTintColor = UIColor.lightGray
            brushSizeSlider.maximumTrackTintColor = UIColor.white
            
            progressBar.tintColor = UIColor.lightGray
            progressBar.trackTintColor = UIColor.white
            
        } else if colorDarkness < 2.67 {
            brushSizeSlider.minimumTrackTintColor = UIColor.black
            brushSizeSlider.maximumTrackTintColor = UIColor.white
            
            progressBar.tintColor = UIColor.black
            progressBar.trackTintColor = UIColor.white
        } else {
            brushSizeSlider.minimumTrackTintColor = UIColor.black
            brushSizeSlider.maximumTrackTintColor = UIColor.lightGray
            
            progressBar.tintColor = UIColor.black
            progressBar.trackTintColor = UIColor.lightGray
        }
        
        if (colorDarkness < 1.87) {
            undoButton.tintColor = .white
            trashButton.tintColor = .white
            dropperButton.tintColor = .white
            paintBucketButton.tintColor = .white
            alphaButton.tintColor = .white
            eraserButton.tintColor = .white
            bullsEyeButton.tintColor = .white
            paintBucketSpinner.color = .white
        } else {
            undoButton.tintColor = .black
            trashButton.tintColor = .black
            dropperButton.tintColor = .black
            paintBucketButton.tintColor = .black
            alphaButton.tintColor = .black
            eraserButton.tintColor = .black
            bullsEyeButton.tintColor = .black
            paintBucketSpinner.color = .black
        }
    }
    
    func uploading(_ progress: Float) {
        undoButton.isHidden = true
        trashButton.isHidden = true
        dropperButton.isHidden = true
        paintBucketButton.isHidden = true
        alphaButton.isHidden = true
        bullsEyeButton.isHidden = true
        brushSizeSlider.isHidden = true
        paintBucketSpinner.isHidden = true
        progressBar.isHidden = false
        progressBar.setProgress(progress, animated: true)
    }
    
    func uploadingFailed() {
        progressBar.progress = 0.0
        undoButton.isHidden = false
        trashButton.isHidden = false
        dropperButton.isHidden = false
        paintBucketButton.isHidden = false
        alphaButton.isHidden = false
        bullsEyeButton.isHidden = false
        paintBucketSpinner.isHidden = false
        brushSizeSlider.isHidden = false
        progressBar.isHidden = true
    }
}

