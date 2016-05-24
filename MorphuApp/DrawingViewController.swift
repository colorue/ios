//
//  ColorKeyboardViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController, UIGestureRecognizerDelegate, ColorKeyboardDelagate, CanvasDelagate {
    
    let api = API.sharedInstance
    let prefs = NSUserDefaults.standardUserDefaults()

    var colorKeyboard: ColorKeyboardView?
    var canvas: CanvasView?
    var underFingerView = UIImageView()
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appMovedToBackground), name: UIApplicationWillResignActiveNotification, object: nil)
        
        let chevron = UIImage(named: "ChevronDown")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.tintColor = UIColor.whiteColor()
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        backButton.setImage(chevron, forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(DrawingViewController.unwind(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        let keyboardHeight = CGFloat(120)

        let canvasHeight = self.view.frame.height - keyboardHeight - 60
        let canvasFrame = CGRect(x: 0.0, y: 0, width: self.view.frame.width, height: canvasHeight)
        
        let prefs = NSUserDefaults.standardUserDefaults()
        var baseImage: UIImage
        
        if let savedDrawing = prefs.stringForKey("savedDrawing") {
            if savedDrawing != "noDrawing" {
                baseImage = UIImage.fromBase64(savedDrawing)
            } else {
                baseImage = UIImage.getImageWithColor(whiteColor, size: canvasFrame.size)
            }
        } else {
            baseImage = UIImage.getImageWithColor(whiteColor, size: canvasFrame.size)
        }

        let canvas = CanvasView(frame: canvasFrame, delagate: self, baseImage: baseImage)
        self.view.addSubview(canvas)
        self.canvas = canvas
 
        let colorKeyboard = ColorKeyboardView(frame: CGRect(x: CGFloat(0.0), y: CGRectGetMaxY(canvas.frame), width: self.view.frame.width, height: keyboardHeight), delagate: self)
        self.view.addSubview(colorKeyboard)
        self.colorKeyboard = colorKeyboard
        
        self.underFingerView.frame = CGRect(x: 0, y: CGRectGetMaxY(canvas.frame) + 0.5, width: keyboardHeight, height: keyboardHeight)
        underFingerView.backgroundColor = UIColor.whiteColor()
        self.underFingerView.hidden = true
        self.view.addSubview(underFingerView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let prefs = NSUserDefaults.standardUserDefaults()
        if (!prefs.boolForKey("drawingHowTo")) {
            let drawingHowTo = UIAlertController(title: "Drawing", message: "Press color buttons to switch colors. Tap color buttons to MIX COLORS! The slider changes the brush size." , preferredStyle: UIAlertControllerStyle.Alert)
            drawingHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(drawingHowTo, animated: true, completion: nil)
            prefs.setValue(true, forKey: "drawingHowTo")
        }
    }
    

    
    func getCurrentColor() -> UIColor {
        return colorKeyboard!.getCurrentColor()
    }
    
    func getCurrentBrushSize() -> Float {
        return colorKeyboard!.getCurrentBrushSize()
    }
    
    func undo() {
        self.canvas!.undo()
    }
    
    func trash() {
        self.canvas!.trash()
    }
    
    func setUnderfingerView(underFingerImage: UIImage) {
        if underFingerView.hidden {
            underFingerView.hidden = false
        }
        underFingerView.image = underFingerImage
    }
    
    func hideUnderFingerView() {
        underFingerView.hidden = true
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        let newDrawing = Drawing(artist: User(), text: canvas!.getDrawing().toBase64(), drawingId: "")
        api.postDrawing(newDrawing)
        
        prefs.setValue("noDrawing", forKey: "savedDrawing")
        
        if (!prefs.boolForKey("getStartedHowToSet")) {
            prefs.setValue(true, forKey: "viewRoundsHowTo")
            prefs.setValue(true, forKey: "getStartedHowToSet")
        }
        
        self.performSegueWithIdentifier("backToHome", sender: self)
    }
    
    func unwind(sender: UIBarButtonItem) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        prefs.setValue(self.canvas?.getDrawing().toBase64(), forKey: "savedDrawing")
        self.performSegueWithIdentifier("backToHome", sender: self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func appMovedToBackground() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("App moved to background!")
        prefs.setValue(self.canvas?.getDrawing().toBase64(), forKey: "savedDrawing")
    }
    
    deinit {
        print("denit")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}