//
//  ColorKeyboardViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import FBSDKShareKit

class DrawingViewController: UIViewController, UIGestureRecognizerDelegate, ColorKeyboardDelagate, CanvasDelagate, UIPopoverPresentationControllerDelegate {
    
    var baseImage: UIImage?
    var prompt: Prompt?

    let api = API.sharedInstance
    let prefs = NSUserDefaults.standardUserDefaults()

    var colorKeyboard: ColorKeyboardView?
    var canvas: CanvasView?
    var underFingerView = UIImageView()
    var keyboardCover = UIView()
    
    let backButton = UIButton(type: UIButtonType.Custom)

    @IBOutlet weak var postButton: UIBarButtonItem!
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "Logo Inactive")!
        let imageView = UIImageView(image:logo)
        imageView.tintColor = blackColor
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
            let drawingHowTo = UIAlertController(title: "Welcome! Get Started Drawing", message: "Press color tabs to switch to their color, tap them to mix a bit of their color with your current color (Shown in the horizontal bar). Change your stroke size with the slider." , preferredStyle: UIAlertControllerStyle.Alert)
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
    
    func startPaintBucketSpinner() {
        colorKeyboard?.paintBucketButton.hidden = true
        colorKeyboard?.paintBucketSpinner.startAnimating()
    }
    
    func stopPaintBucketSpinner() {
        colorKeyboard?.paintBucketSpinner.stopAnimating()
        colorKeyboard?.paintBucketButton.hidden = false
    }
    
    func getKeyboardState() -> KeyboardToolState {
        return self.colorKeyboard?.state ?? .none
    }
    
    func setKeyboardState(state: KeyboardToolState) {
        self.colorKeyboard?.state = state
    }
    
    func setDropperActive(active: Bool) {
        if active {
            if (!prefs.boolForKey("dropperHowTo")) {
                let dropperHowTo = UIAlertController(title: "Color Dropper Tool", message: "Tap on or drag to a color on the canvas to switch to it." , preferredStyle: UIAlertControllerStyle.Alert)
                dropperHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(dropperHowTo, animated: true, completion: nil)
                prefs.setValue(true, forKey: "dropperHowTo")
            }
        }
        self.colorKeyboard?.state = .colorDropper
        self.colorKeyboard!.updateButtonColor()
    }
    
    func switchAlphaHowTo() {
        if (!prefs.boolForKey("alphaHowTo")) {
            let alphaHowTo = UIAlertController(title: "Opacity Rotator", message: "Tap this button to rotate through solid, sorta transparent, and mostly transparent lines.", preferredStyle: UIAlertControllerStyle.Alert)
            alphaHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alphaHowTo, animated: true, completion: nil)
            prefs.setValue(true, forKey: "alphaHowTo")
        }
    }
    
    func postDrawing() {
        self.baseImage = nil
        self.postButton.enabled = false
        self.colorKeyboard!.uploading(0)
        self.view.userInteractionEnabled = false
        
        let newDrawing = Drawing(artist: User(), drawingId: "")
        newDrawing.setImage((canvas?.getDrawing())!)
        
        api.postDrawing(newDrawing, progressCallback: self.colorKeyboard!.uploading, prompt: prompt, finishedCallback: postCallback)

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
        self.save()

        if (!prefs.boolForKey("firstCloseCanvas")) {
            let firstCloseCanvas = UIAlertController(title: "Close Canvas?", message: "Don't worry your drawing is saved" , preferredStyle: UIAlertControllerStyle.Alert)
            firstCloseCanvas.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alert in
                NSNotificationCenter.defaultCenter().removeObserver(self)
                self.performSegueWithIdentifier("backToHome", sender: self)
            }))
            firstCloseCanvas.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))

            self.presentViewController(firstCloseCanvas, animated: true, completion: nil)
            prefs.setValue(true, forKey: "firstCloseCanvas")
        } else {
            NSNotificationCenter.defaultCenter().removeObserver(self)
            self.performSegueWithIdentifier("backToHome", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveToHome" {
            let targetController = segue.destinationViewController as! WallViewController
            targetController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        } else if  segue.identifier == "toShare" {
            let dvc = segue.destinationViewController as! SharingViewController
            let controller = dvc.popoverPresentationController
            if let controller = controller {
                controller.delegate = self
            }
            dvc.drawing = canvas?.getDrawing()
            dvc.popoverController = self
            
            dvc.preferredContentSize = CGSize(width: self.view.frame.width, height: (self.view.frame.width - 75.0))
            
            self.view.alpha = 0.4
            self.navigationController?.navigationBar.alpha = 0.4
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.save()

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func appMovedToBackground() {
        self.save()
        self.hideUnderFingerView()
        
//        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverController: UIPopoverPresentationController) -> Bool  {
        UIView.animateWithDuration(0.3, animations: {
            self.view.alpha = 1.0
            self.navigationController?.navigationBar.alpha = 1.0
        })
        return true
   }
}