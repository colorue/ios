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
    let progressBar = UIProgressView()
    
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
        
        currentColorView.backgroundColor = colors[Int(arc4random_uniform(8) + 1)]
        currentColorView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: selectorWidth)
        self.addSubview(currentColorView)
        
        brushSizeSlider.minimumTrackTintColor = UIColor.lightGrayColor()
        brushSizeSlider.maximumTrackTintColor = UIColor.whiteColor()
        brushSizeSlider.maximumValue = 10.0
        brushSizeSlider.minimumValue = 1.5
        brushSizeSlider.value = 5.5
        brushSizeSlider.center = CGPoint(x: self.frame.width/2.0, y: selectorWidth/2.0)
        self.addSubview(brushSizeSlider)
        
        undoButton.setImage(UIImage(named: "UndoIcon")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        undoButton.tintColor = .whiteColor()
        undoButton.addTarget(self, action: #selector(ColorKeyboardView.undo(_:)), forControlEvents: .TouchUpInside)
        undoButton.frame = CGRect(x: frame.maxX - 8 - selectorWidth/3 * 2, y: (selectorWidth - (height: selectorWidth/3 * 2))/2, width: selectorWidth/3 * 2, height: selectorWidth/3 * 2)
        self.addSubview(undoButton)
        
        
        dropperButton.setImage(UIImage(named: "Like")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        dropperButton.setImage(UIImage(named: "Liked")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)

        dropperButton.tintColor = .whiteColor()
        dropperButton.addTarget(self, action: #selector(ColorKeyboardView.dropper(_:)), forControlEvents: .TouchUpInside)
        dropperButton.frame = CGRect(x: frame.maxX - 75 - selectorWidth/3 * 2, y: (selectorWidth - (height: selectorWidth/3 * 2))/2, width: selectorWidth/3 * 2, height: selectorWidth/3 * 2)
//        self.addSubview(dropperButton)
        
        trashButton.setImage(UIImage(named: "TrashIcon")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        trashButton.tintColor = .whiteColor()
        trashButton.addTarget(self, action: #selector(ColorKeyboardView.trash(_:)), forControlEvents: .TouchUpInside)
        trashButton.frame = CGRect(x: frame.minX + 8, y: (selectorWidth - (height: selectorWidth/3 * 2))/2, width: selectorWidth/3 * 2, height: selectorWidth/3 * 2)
        self.addSubview(trashButton)
        
        let separatorU = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0.5))
        separatorU.backgroundColor = dividerColor
        self.addSubview(separatorU)
        
        self.progressBar.frame = CGRect(x: 0, y: 0, width: self.frame.width/2, height: 0)
        self.progressBar.center = self.currentColorView.center
        self.progressBar.progress = 0.5
        self.progressBar.hidden = true
        self.addSubview(progressBar)
        
        updateButtonColor()
    }
    
    func colorButton(withColor color:UIColor, tag: Int) -> UIButton {
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
    
    func undo(sender: UIButton) {
        delagate.undo()
    }
    
    func trash(sender: UIButton) {
        delagate.trash()
    }
    
    func dropper(sender: UIButton) {
        self.delagate.setDropperActive(!self.delagate.getDropperActive())
        self.setDropper()
    }
    
    
    func setDropper() {
        self.dropperButton.selected = self.delagate.getDropperActive()
    }
    
    func buttonHeld(sender: UITapGestureRecognizer) {
        currentColorView.backgroundColor = colors[sender.view!.tag]
        updateButtonColor()
    }
    
    func buttonTapped(sender: UIButton) {
        let percentMix: CGFloat = 0.1
        currentColorView.backgroundColor = self.blendColor(currentColorView.backgroundColor!, withColor: colors[sender.tag], percentMix: percentMix)
        updateButtonColor()
    }
    
    func blendColor(color1: UIColor, withColor color2: UIColor, percentMix: CGFloat) -> UIColor {
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
    
    func setColor(color: UIColor) {
        self.currentColorView.backgroundColor = color
        
        updateButtonColor()
    }
    
    func updateButtonColor() {
        let coreColor = currentColorView.backgroundColor?.coreImageColor!
        let colorDarkness = coreColor!.red + coreColor!.green + coreColor!.blue
        if (colorDarkness < 1.2) {
            brushSizeSlider.minimumTrackTintColor = UIColor.lightGrayColor()
            brushSizeSlider.maximumTrackTintColor = UIColor.whiteColor()
            
            progressBar.tintColor = UIColor.lightGrayColor()
            progressBar.trackTintColor = UIColor.whiteColor()
        } else if colorDarkness < 2.0 {
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
        
        if (colorDarkness < 1.4) {
            undoButton.tintColor = .whiteColor()
            trashButton.tintColor = .whiteColor()
            dropperButton.tintColor = .whiteColor()
        } else {
            undoButton.tintColor = .blackColor()
            trashButton.tintColor = .blackColor()
            dropperButton.tintColor = .blackColor()
        }
    }
    
    func uploading(progress: Float) {
        undoButton.hidden = true
        trashButton.hidden = true
        brushSizeSlider.hidden = true
        
        progressBar.hidden = false
        progressBar.progress = progress
    }
    
    func uploadingFailed() {
        undoButton.hidden = false
        trashButton.hidden = false
        brushSizeSlider.hidden = false
        
        progressBar.hidden = true
    }
}

