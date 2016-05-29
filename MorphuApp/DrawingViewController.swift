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
    
    let backButton = UIButton(type: UIButtonType.Custom)

    @IBOutlet weak var postButton: UIBarButtonItem!
    private var dropperActive = false

    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "Logo Inactive")! // UIImage(named: "Logo Clear")!
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appMovedToBackground), name: UIApplicationWillResignActiveNotification, object: nil)
        
        let chevron = UIImage(named: "ChevronDown")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
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
        
        if prefs.boolForKey("saved") {
            if let savedDrawing = prefs.stringForKey("savedDrawing") {
                baseImage = UIImage.fromBase64(savedDrawing)
            } else {
                baseImage = UIImage.getImageWithColor(whiteColor, size: CGSize(width: canvasFrame.width * 2, height: canvasFrame.height * 2))
            }
        } else {
            baseImage = UIImage.getImageWithColor(whiteColor, size: CGSize(width: canvasFrame.width * 2, height: canvasFrame.height * 2))
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
        
        prefs.setValue(true, forKey: "saved")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (!prefs.boolForKey("drawingHowTo")) {
            let drawingHowTo = UIAlertController(title: "Drawing", message: "Tap a color selectors to mix colors. Press them to switch colors.  The slider changes the brush size." , preferredStyle: UIAlertControllerStyle.Alert)
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
    
    func dropper() {
        self.canvas!.dropper()
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
    
    func setColor(color: UIColor) {
        self.colorKeyboard!.setColor(color)
    }
    
    func getDropperActive() -> Bool {
        return self.dropperActive
    }
    
    func setDropperActive(active: Bool) {
        self.dropperActive = active
        self.colorKeyboard!.setDropper()
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        self.postButton.enabled = false
        self.colorKeyboard!.uploading(0)
        self.view.userInteractionEnabled = false
        
        let newDrawing = Drawing(artist: User(), drawingId: "")
        newDrawing.setImage((canvas?.getDrawing())!)
        
        api.postDrawing(newDrawing, progressCallback: self.colorKeyboard!.uploading, finishedCallback: postCallback)
    }
    
    func postCallback(uploaded: Bool) {
        if uploaded {
            prefs.setValue(false, forKey: "saved")

            NSNotificationCenter.defaultCenter().removeObserver(self)
            self.performSegueWithIdentifier("backToHome", sender: self)
        } else {
            self.colorKeyboard!.uploadingFailed()
            self.view.userInteractionEnabled = true
            self.postButton.enabled = true
        }
    }
    
    func unwind(sender: UIBarButtonItem) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.save()
        self.backButton.enabled = false
        self.performSegueWithIdentifier("backToHome", sender: self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.save()

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func appMovedToBackground() {
        self.save()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func save() {
        
        let color = self.colorKeyboard?.getCurrentColor()
        
        prefs.setValue(color?.coreImageColor!.red, forKey: "colorRed")
        prefs.setValue(color?.coreImageColor!.green, forKey: "colorGreen")
        prefs.setValue(color?.coreImageColor!.blue, forKey: "colorBlue")
        prefs.setValue(sqrt((self.colorKeyboard?.getCurrentBrushSize())!), forKey: "brushSize")
        prefs.setValue(self.canvas?.getDrawing().toBase64(), forKey: "savedDrawing")
    }
}