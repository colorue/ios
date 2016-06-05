//
//  ColorKeyboardView.swift
//  Morphu
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class ColorKeyboardView: UIView, UIGestureRecognizerDelegate {
    let selectorWidth: CGFloat
    let currentColorView = UIView()
    let brushSizeSlider = UISlider()
    let undoButton = UIButton()
    let trashButton = UIButton()
    let dropperButton = UIButton()
    let eraserButton = UIButton()
    let alphaButton = UIButton()
    let progressBar = UIProgressView()
    private let prefs = NSUserDefaults.standardUserDefaults()
    
    private var currentAlpha = AlphaType.High
    
    enum AlphaType: CGFloat {
        case High = 1.0
        case Medium = 0.7
        case Low = 0.3
    }

    let delagate: ColorKeyboardDelagate
    
    init (frame: CGRect, delagate: ColorKeyboardDelagate) {
        self.selectorWidth = frame.width/10
        self.delagate = delagate
        super.init(frame : frame)
        displayKeyboard()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func displayKeyboard() {
        
        for tag in 0...9 {
            self.addSubview(colorButton(withColor: colors[tag], tag: tag))
        }
        
        currentColorView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: selectorWidth)
        self.addSubview(currentColorView)
        
        
        brushSizeSlider.minimumTrackTintColor = UIColor.lightGrayColor()
        brushSizeSlider.maximumTrackTintColor = UIColor.whiteColor()
        brushSizeSlider.maximumValue = 10.0
        brushSizeSlider.minimumValue = 1.5
        
        brushSizeSlider.center = CGPoint(x: self.frame.width/2.0, y: selectorWidth/2.0)
        self.addSubview(brushSizeSlider)
        
        let buttonSize = selectorWidth
        
        undoButton.setImage(UIImage(named: "UndoIcon")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        undoButton.tintColor = .whiteColor()
        undoButton.addTarget(self, action: #selector(ColorKeyboardView.undo(_:)), forControlEvents: .TouchUpInside)
        undoButton.frame = CGRect(x: buttonSize, y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        undoButton.showsTouchWhenHighlighted = true
        self.addSubview(undoButton)
        
        trashButton.setImage(UIImage(named: "TrashIcon")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        trashButton.tintColor = .whiteColor()
        trashButton.addTarget(self, action: #selector(ColorKeyboardView.trash(_:)), forControlEvents: .TouchUpInside)
        trashButton.frame = CGRect(x: frame.minX, y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        trashButton.showsTouchWhenHighlighted = true
        self.addSubview(trashButton)
        
        dropperButton.setImage(UIImage(named: "Dropper")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        dropperButton.setImage(UIImage(named: "DropperActive")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        dropperButton.tintColor = .whiteColor()
        dropperButton.addTarget(self, action: #selector(ColorKeyboardView.dropper(_:)), forControlEvents: .TouchUpInside)
        dropperButton.frame = CGRect(x: frame.maxX - buttonSize, y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        dropperButton.showsTouchWhenHighlighted = true
        self.addSubview(dropperButton)
        
        
        alphaButton.tintColor = .whiteColor()
        alphaButton.addTarget(self, action: #selector(ColorKeyboardView.switchAlpha(_:)), forControlEvents: .TouchUpInside)
        alphaButton.frame = CGRect(x: frame.maxX - buttonSize - buttonSize, y: (selectorWidth - buttonSize)/2, width: buttonSize, height: buttonSize)
        alphaButton.showsTouchWhenHighlighted = true
        self.addSubview(alphaButton)


        let separatorU = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0.5))
        separatorU.backgroundColor = dividerColor
        self.addSubview(separatorU)
        
        self.progressBar.frame = CGRect(x: 0, y: 0, width: self.frame.width/2, height: 0)
        self.progressBar.center = self.currentColorView.center
        self.progressBar.progress = 0.0
        self.progressBar.hidden = true
        self.addSubview(progressBar)
        
        if prefs.boolForKey("saved") {
            let red = CGFloat(prefs.floatForKey("colorRed"))
            let green = CGFloat(prefs.floatForKey("colorGreen"))
            let blue = CGFloat(prefs.floatForKey("colorBlue"))
            
            let alpha = CGFloat(prefs.floatForKey("alpha"))
            
            switch (round(1000 * alpha) / 1000) {
            case AlphaType.Low.rawValue:
                alphaButton.setImage(UIImage(named: "Alpha Low")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                currentAlpha = .Low
            case AlphaType.Medium.rawValue:
                alphaButton.setImage(UIImage(named: "Alpha Mid")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                currentAlpha = .Medium
            default:
                alphaButton.setImage(UIImage(named: "Alpha High")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                currentAlpha = .High
            }

            currentColorView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            brushSizeSlider.value = prefs.floatForKey("brushSize")
        } else {
            brushSizeSlider.value = 5.5
            currentColorView.backgroundColor = colors[Int(arc4random_uniform(8) + 1)]
            alphaButton.setImage(UIImage(named: "Alpha High")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        
        updateButtonColor()
    }
    
    private func colorButton(withColor color:UIColor, tag: Int) -> UIButton {
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
        delagate.undo()
    }
    
    @objc private func trash(sender: UIButton) {
        delagate.trash()
    }
    
    @objc private func dropper(sender: UIButton) {
        self.delagate.setDropperActive(!self.delagate.getDropperActive())
        self.setDropper()
    }
    
    @objc private func eraser(sender: UIButton) {
        self.currentAlpha = .High
        alphaButton.setImage(UIImage(named: "Alpha High")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.currentColorView.backgroundColor = whiteColor
        updateButtonColor()
    }
    
    @objc private func switchAlpha(sender: UIButton) {
        switch(currentAlpha) {
        case .High:
            self.currentAlpha = .Medium
            alphaButton.setImage(UIImage(named: "Alpha Mid")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        case .Medium:
            self.currentAlpha = .Low
            alphaButton.setImage(UIImage(named: "Alpha Low")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        case .Low:
            self.currentAlpha = .High
            alphaButton.setImage(UIImage(named: "Alpha High")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
    }
    
    
    func setDropper() {
        self.dropperButton.selected = self.delagate.getDropperActive()
        self.dropperButton.highlighted = self.delagate.getDropperActive()
    }
    
    @objc private func buttonHeld(sender: UITapGestureRecognizer) {
        currentColorView.backgroundColor = colors[sender.view!.tag]
        updateButtonColor()
    }
    
    @objc private func buttonTapped(sender: UIButton) {
        let percentMix: CGFloat = 0.1
        currentColorView.backgroundColor = self.blendColor(currentColorView.backgroundColor!, withColor: colors[sender.tag], percentMix: percentMix)
        updateButtonColor()
    }
    
    private func blendColor(color1: UIColor, withColor color2: UIColor, percentMix: CGFloat) -> UIColor {
        let c1 = color1.coreImageColor!
        let c2 = color2.coreImageColor!
        return UIColor(red: c1.red * (1 - percentMix) + c2.red * percentMix, green: c1.green * (1 - percentMix) + c2.green * percentMix, blue: c1.blue * (1 - percentMix) + c2.blue * percentMix, alpha: 1.0)
    }
    
    func getCurrentColor() -> UIColor {
        return self.currentColorView.backgroundColor!
    }
    
    func getCurrentBrushSize() -> Float {
        return brushSizeSlider.value * brushSizeSlider.value
    }
    
    func getAlpha() -> CGFloat? {
        return self.currentAlpha.rawValue
    }
    
    func setAlphaHigh() {
        self.currentAlpha = .High
        alphaButton.setImage(UIImage(named: "Alpha High")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    }
    
    func setColor(color: UIColor) {
        self.currentColorView.backgroundColor = color
        
        updateButtonColor()
    }
    
    private func updateButtonColor() {
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
            alphaButton.tintColor = .whiteColor()
            eraserButton.tintColor = .whiteColor()
        } else {
            undoButton.tintColor = .blackColor()
            trashButton.tintColor = .blackColor()
            dropperButton.tintColor = .blackColor()
            alphaButton.tintColor = .blackColor()
            eraserButton.tintColor = .blackColor()
        }
    }
    
    func uploading(progress: Float) {
        undoButton.hidden = true
        trashButton.hidden = true
        dropperButton.hidden = true
        alphaButton.hidden = true
        brushSizeSlider.hidden = true
        
        progressBar.hidden = false
        progressBar.setProgress(progress, animated: true)
    }
    
    func uploadingFailed() {
        self.progressBar.progress = 0.0
        undoButton.hidden = false
        trashButton.hidden = false
        dropperButton.hidden = false
        alphaButton.hidden = false
        brushSizeSlider.hidden = false
        
        progressBar.hidden = true
    }
}

