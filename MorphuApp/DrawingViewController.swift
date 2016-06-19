//
//  ColorKeyboardViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController, UIGestureRecognizerDelegate, ColorKeyboardDelagate, CanvasDelagate {
    
    var baseImage: UIImage?

    let api = API.sharedInstance
    let prefs = NSUserDefaults.standardUserDefaults()

    var colorKeyboard: ColorKeyboardView?
    var canvas: CanvasView?
    var underFingerView = UIImageView()
    var keyboardCover = UIView()
    
    let backButton = UIButton(type: UIButtonType.Custom)

    @IBOutlet weak var postButton: UIBarButtonItem!
    private var dropperActive = false

    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "Logo Clear")! 
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appMovedToBackground), name: UIApplicationWillResignActiveNotification, object: nil)
        
        let chevron = UIImage(named: "ChevronDown")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        backButton.tintColor = blackColor
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        backButton.setImage(chevron, forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(DrawingViewController.unwind(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        let keyboardHeight = self.view.frame.height / 5.55833333333333
        let canvasHeight = self.view.frame.height - keyboardHeight - 60
        
        let canvasFrame = CGRect(x:(self.view.frame.width - canvasHeight/1.3)/2, y: 0, width: canvasHeight/1.3, height: canvasHeight)
        
        
        if prefs.boolForKey("saved") {
            if baseImage == nil {
                if let savedDrawing = prefs.stringForKey("savedDrawing") {
                    baseImage = UIImage.fromBase64(savedDrawing)
                }
            }
        }
        
        let canvas = CanvasView(frame: canvasFrame, delagate: self, baseImage: baseImage)
//        let canvas = SmoothedCanvas(frame: canvasFrame)
        
        self.view.addSubview(canvas)
        self.canvas = canvas
        
        let colorKeyboardFrame = CGRect(x: CGFloat(0.0), y: CGRectGetMaxY(canvas.frame), width: self.view.frame.width, height: keyboardHeight)
        let colorKeyboard = ColorKeyboardView(frame: colorKeyboardFrame, delagate: self)
        self.view.addSubview(colorKeyboard)
        self.colorKeyboard = colorKeyboard
        
        self.keyboardCover.frame = colorKeyboardFrame
        keyboardCover.backgroundColor = UIColor.blackColor()
        self.keyboardCover.alpha = 0.0
        self.view.addSubview(keyboardCover)
        
        

        
        self.underFingerView.frame = CGRect(x: canvas.frame.midX - (keyboardHeight/2), y: CGRectGetMaxY(canvas.frame) + 0.5, width: keyboardHeight, height: keyboardHeight)
        underFingerView.backgroundColor = UIColor.whiteColor()
        self.underFingerView.alpha = 0.0
        self.view.addSubview(underFingerView)
        
        prefs.setValue(true, forKey: "saved")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (!prefs.boolForKey("drawingHowTo")) {
            let drawingHowTo = UIAlertController(title: "Drawing", message: "Tap a color selector to mix colors. Press them to switch colors.  The slider changes the brush size." , preferredStyle: UIAlertControllerStyle.Alert)
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
    
    func getAlpha() -> CGFloat? {
        return colorKeyboard?.getAlpha()
    }
    
    func setAlphaHigh() {
        colorKeyboard?.setAlphaHigh()
    }
    
    func undo() {
        self.canvas!.undo()
    }
    
    func trash() {
        
        let deleteAlert = UIAlertController(title: "Clear drawing?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action: UIAlertAction!) in
            self.canvas!.trash()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil ))
        self.presentViewController(deleteAlert, animated: true, completion: nil)
    }
    
    func setUnderfingerView(underFingerImage: UIImage) {
        self.colorKeyboard?.userInteractionEnabled = false
        if underFingerView.hidden {
            underFingerView.hidden = false
        }
        underFingerView.image = underFingerImage
    }
    
    func hideUnderFingerView() {
        self.colorKeyboard?.userInteractionEnabled = true
        UIView.animateWithDuration(0.5,delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.underFingerView.alpha = 0.0
            self.keyboardCover.alpha = 0.0
            }, completion: nil)
    }
    
    func showUnderFingerView() {
        self.colorKeyboard?.userInteractionEnabled = false
        UIView.animateWithDuration(0.5,delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.underFingerView.alpha = 1.0
            self.keyboardCover.alpha = 0.5
        }, completion: nil)
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
        self.colorKeyboard!.updateButtonColor()
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        
        self.baseImage = nil
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
            self.performSegueWithIdentifier("saveToHome", sender: self)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveToHome" {
            let targetController = segue.destinationViewController as! WallViewController
            
            targetController.tableView.setContentOffset(CGPointZero, animated: true)

        }
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
        prefs.setValue(self.colorKeyboard?.getCurrentBrushSize(), forKey: "brushSize")
        prefs.setValue(self.canvas?.getDrawing().toBase64(), forKey: "savedDrawing")
        
        prefs.setValue(colorKeyboard?.getAlpha(), forKey: "alpha")
    }
}