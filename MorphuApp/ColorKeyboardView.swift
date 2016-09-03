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
    private let prefs = NSUserDefaults.standardUserDefaults()
    
    let sliderConstant:Float = 2.0
    
    var state: KeyboardToolState = .none {
        didSet {
            dropperButton.selected = state == .colorDropper
            paintBucketButton.selected = state == .paintBucket
            bullsEyeButton.selected = state == .bullsEye
        }
    }
    
    private var currentAlpha = AlphaType.High {
        didSet {
            switch(currentAlpha) {
            case .High:
                alphaButton.setImage(R.image.alphaHigh(), forState: .Normal)
            case .Medium:
                alphaButton.setImage(R.image.alphaMid(), forState: .Normal)
            case .Low:
                alphaButton.setImage(R.image.alphaLow(), forState: .Normal)
            }
        }
    }
    
    enum AlphaType: CGFloat {
        case High = 1.0
        case Medium = 0.7
        case Low = 0.3
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
        
        
        brushSizeSlider.minimumTrackTintColor = UIColor.lightGrayColor()
        brushSizeSlider.maximumTrackTintColor = UIColor.whiteColor()
        brushSizeSlider.maximumValue = pow(100, 1/sliderConstant)
        brushSizeSlider.minimumValue = pow(1, 1/sliderConstant)
        
        brushSizeSlider.center = CGPoint(x: frame.width/2.0, y: selectorWidth/2.0)
        
        brushSizeSlider.addTarget(self, action: #selector(ColorKeyboardView.sliderChanged(_:)), forControlEvents: .TouchUpInside)
        addSubview(brushSizeSlider)
        
        let buttonSize = selectorWidth
        
        undoButton.setImage(R.image.undoIcon(), forState: .Normal)
        undoButton.tintColor = .whiteColor()
        undoButton.addTarget(self, action: #selector(ColorKeyboardView.undo(_:)), forControlEvents: .TouchUpInside)
        undoButton.frame = CGRect(x: frame.minX + buttonSize, y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        undoButton.showsTouchWhenHighlighted = true
        addSubview(undoButton)
        
        trashButton.setImage(R.image.trashIcon(), forState: .Normal)
        trashButton.tintColor = .whiteColor()
        trashButton.addTarget(self, action: #selector(ColorKeyboardView.trash(_:)), forControlEvents: .TouchUpInside)
        trashButton.frame = CGRect(x: frame.minX, y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        trashButton.showsTouchWhenHighlighted = true
        addSubview(trashButton)
        
        paintBucketButton.setImage(R.image.paintBucket(), forState: .Normal)
        paintBucketButton.setImage(R.image.paintBucketActive(), forState: .Selected)
        paintBucketButton.tintColor = .whiteColor()
        paintBucketButton.addTarget(self, action: #selector(ColorKeyboardView.paintBucket(_:)), forControlEvents: .TouchUpInside)
        paintBucketButton.frame = CGRect(x: frame.maxX - (buttonSize * 1), y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        paintBucketButton.showsTouchWhenHighlighted = true
        addSubview(paintBucketButton)
        
        paintBucketSpinner.hidesWhenStopped = true
        paintBucketSpinner.center = paintBucketButton.center
        paintBucketSpinner.color = .whiteColor()
        addSubview(paintBucketSpinner)
        
        dropperButton.setImage(R.image.dropper(), forState: .Normal)
        dropperButton.setImage(R.image.dropperActive(), forState: .Selected)
        dropperButton.tintColor = .whiteColor()
        dropperButton.addTarget(self, action: #selector(ColorKeyboardView.dropper(_:)), forControlEvents: .TouchUpInside)
        dropperButton.frame = CGRect(x: frame.maxX - (buttonSize * 2), y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        dropperButton.showsTouchWhenHighlighted = true
        addSubview(dropperButton)
        
        bullsEyeButton.setImage(R.image.bullsEye(), forState: .Normal)
        bullsEyeButton.setImage(R.image.bullsEyeActive(), forState: .Selected)
        bullsEyeButton.tintColor = .whiteColor()
        bullsEyeButton.addTarget(self, action: #selector(ColorKeyboardView.bullsEye(_:)), forControlEvents: .TouchUpInside)
        bullsEyeButton.frame = CGRect(x: frame.maxX - (buttonSize * 3), y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        bullsEyeButton.showsTouchWhenHighlighted = true
        addSubview(bullsEyeButton)
        
        alphaButton.tintColor = .whiteColor()
        alphaButton.addTarget(self, action: #selector(ColorKeyboardView.switchAlpha(_:)), forControlEvents: .TouchUpInside)
        alphaButton.frame = CGRect(x: frame.minX + (buttonSize * 2), y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        alphaButton.showsTouchWhenHighlighted = true
        addSubview(alphaButton)

        let separatorU = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 0.5))
        separatorU.backgroundColor = UIColor.lightGrayColor()
        addSubview(separatorU)
        
        progressBar.frame = CGRect(x: 0, y: 0, width: frame.width/2, height: 0)
        progressBar.center = currentColorView.center
        progressBar.progress = 0.0
        progressBar.hidden = true
        addSubview(progressBar)
        
        if prefs.boolForKey(Prefs.saved) {
            let red = CGFloat(prefs.floatForKey(Prefs.colorRed))
            let green = CGFloat(prefs.floatForKey(Prefs.colorGreen))
            let blue = CGFloat(prefs.floatForKey(Prefs.colorBlue))
            let alpha = CGFloat(prefs.floatForKey(Prefs.colorAlpha))
            
            switch (round(1000 * alpha) / 1000) {
            case AlphaType.Low.rawValue:
                currentAlpha = .Low
            case AlphaType.Medium.rawValue:
                currentAlpha = .Medium
            default:
                currentAlpha = .High
            }

            currentColorView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            brushSizeSlider.value = pow(prefs.floatForKey(Prefs.brushSize), 1/sliderConstant)
        } else {
            brushSizeSlider.value = (brushSizeSlider.maximumValue + brushSizeSlider.minimumValue) / 2
            currentColorView.backgroundColor = colors[Int(arc4random_uniform(8) + 1)]
        }
        
        updateButtonColor()
    }
    
    private func colorButton(withColor color:UIColor, tag: Int, selectorWidth: CGFloat) -> UIButton {
        let newButton = UIButton()
        newButton.backgroundColor = color
        newButton.tag = tag
        newButton.addTarget(self, action: #selector(ColorKeyboardView.buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        newButton.frame = CGRect(x: frame.minX + CGFloat(tag) * selectorWidth, y: selectorWidth, width: selectorWidth, height: frame.height - selectorWidth)
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(ColorKeyboardView.buttonHeld(_:)))
        tap.minimumPressDuration = 0.15
        tap.delegate = self
        newButton.addGestureRecognizer(tap)
        
        return newButton
    }
    
    @objc private func undo(sender: UIButton) {
        delagate?.undo()
//        state = .none
    }
    
    @objc private func trash(sender: UIButton) {
        delagate?.trash()
        state = .none
    }
    
    @objc private func dropper(sender: UIButton) {
        state = state == .colorDropper ? .none : .colorDropper
    }
    
    @objc private func paintBucket(sender: UIButton) {
        state = state == .paintBucket ? .none : .paintBucket
    }
    
    @objc private func bullsEye(sender: UIButton) {
        state = state == .bullsEye ? .none : .bullsEye
    }
    
    @objc private func sliderChanged(sender: UISlider) {
        sender.setValue(Float(lroundf(sender.value)), animated: true)
    }
    
    @objc private func switchAlpha(sender: UIButton) {
        switch(currentAlpha) {
        case .High:
            currentAlpha = .Medium
        case .Medium:
            currentAlpha = .Low
        case .Low:
            currentAlpha = .High
        }
        delagate?.switchAlphaHowTo()
    }
    
    @objc private func buttonHeld(sender: UITapGestureRecognizer) {
        currentColorView.backgroundColor = colors[sender.view!.tag]
        updateButtonColor()
//        state = .none
    }
    
    @objc private func buttonTapped(sender: UIButton) {
        let percentMix: CGFloat = 0.1
        currentColorView.backgroundColor = blendColor(currentColorView.backgroundColor!, withColor: colors[sender.tag], percentMix: percentMix)

        updateButtonColor()
//        state = .none
    }
    
    private func blendColor(color1: UIColor, withColor color2: UIColor, percentMix: CGFloat) -> UIColor {
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
        currentAlpha = .High
    }
    
    func setColor(color: UIColor) {
        setCurrentColor(color, animationTime: 0.5)
    }
    
    private func setCurrentColor(color: UIColor, animationTime: Double) {
        UIView.animateWithDuration(animationTime,delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.currentColorView.backgroundColor = color
            }, completion: nil)
    }
    
    func updateButtonColor() {
        let coreColor = currentColorView.backgroundColor?.coreImageColor!
        let colorDarkness = coreColor!.red + coreColor!.green * 2.0 + coreColor!.blue
        
        if (colorDarkness < 1.6) {
            brushSizeSlider.minimumTrackTintColor = UIColor.lightGrayColor()
            brushSizeSlider.maximumTrackTintColor = UIColor.whiteColor()
            
            progressBar.tintColor = UIColor.lightGrayColor()
            progressBar.trackTintColor = UIColor.whiteColor()
            
        } else if colorDarkness < 2.67 {
            brushSizeSlider.minimumTrackTintColor = UIColor.blackColor()
            brushSizeSlider.maximumTrackTintColor = UIColor.whiteColor()
            
            progressBar.tintColor = UIColor.blackColor()
            progressBar.trackTintColor = UIColor.whiteColor()
        } else {
            brushSizeSlider.minimumTrackTintColor = UIColor.blackColor()
            brushSizeSlider.maximumTrackTintColor = UIColor.lightGrayColor()
            
            progressBar.tintColor = UIColor.blackColor()
            progressBar.trackTintColor = UIColor.lightGrayColor()
        }
        
        if (colorDarkness < 1.87) {
            undoButton.tintColor = .whiteColor()
            trashButton.tintColor = .whiteColor()
            dropperButton.tintColor = .whiteColor()
            paintBucketButton.tintColor = .whiteColor()
            alphaButton.tintColor = .whiteColor()
            eraserButton.tintColor = .whiteColor()
            bullsEyeButton.tintColor = .whiteColor()
            paintBucketSpinner.color = .whiteColor()
        } else {
            undoButton.tintColor = .blackColor()
            trashButton.tintColor = .blackColor()
            dropperButton.tintColor = .blackColor()
            paintBucketButton.tintColor = .blackColor()
            alphaButton.tintColor = .blackColor()
            eraserButton.tintColor = .blackColor()
            bullsEyeButton.tintColor = .blackColor()
            paintBucketSpinner.color = .blackColor()
        }
    }
    
    func uploading(progress: Float) {
        undoButton.hidden = true
        trashButton.hidden = true
        dropperButton.hidden = true
        paintBucketButton.hidden = true
        alphaButton.hidden = true
        brushSizeSlider.hidden = true
        paintBucketSpinner.hidden = true
        progressBar.hidden = false
        progressBar.setProgress(progress, animated: true)
    }
    
    func uploadingFailed() {
        progressBar.progress = 0.0
        undoButton.hidden = false
        trashButton.hidden = false
        dropperButton.hidden = false
        paintBucketButton.hidden = false
        alphaButton.hidden = false
        paintBucketSpinner.hidden = false
        brushSizeSlider.hidden = false
        progressBar.hidden = true
    }
}

