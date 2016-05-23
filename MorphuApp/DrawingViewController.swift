//
//  ColorKeyboardViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController, UIGestureRecognizerDelegate, ColorKeyboardDelagate, CanvasDelagate {
    let model = API.sharedInstance
    var colorKeyboard: ColorKeyboardView?
    var canvas: CanvasView?
    var descriptionInstance: Content?
    var underFingerView = UIImageView()
    var chainInstance = Chain()
    var nextUser = User()
    var finishChain = false
    
    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var actionIcon: UIImageView!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var timeCreated: UILabel!
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let chevron = UIImage(named: "ChevronDown")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.tintColor = UIColor.whiteColor()
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        backButton.setImage(chevron, forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(DrawingViewController.unwind(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        
        let keyboardHeight = CGFloat(120)

        let canvasFrame = CGRect(x: 0.0, y: 0, width: self.view.frame.width, height: self.view.frame.height - keyboardHeight - 60)
        let canvas = CanvasView(frame: canvasFrame, delagate: self, baseImage: UIImage.getImageWithColor(whiteColor, size: canvasFrame.size))
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
    
    @IBAction func done(sender: UIBarButtonItem) {
        
        let newDrawing = Content(author: User(), isDrawing: true, text: canvas!.getDrawing().toBase64(), chainId: "", contentId: "")
        
        if self.finishChain {
            model.finishChain(chainInstance, content: newDrawing)
        } else {
            model.addToChain(chainInstance, content: newDrawing, nextUser: nextUser)
        }
        self
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if (!prefs.boolForKey("getStartedHowToSet")) {
            prefs.setValue(true, forKey: "viewRoundsHowTo")
            prefs.setValue(true, forKey: "getStartedHowToSet")
        }
        
        self.performSegueWithIdentifier("unwindToInbox", sender: self)
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
    
    func unwind(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("backToHome", sender: self)
    }
}