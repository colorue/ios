//
//  NewThreadViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/13/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class NewThreadViewController: UIViewController, CanvasDelagate, ColorKeyboardDelagate, DescriptionInputDelagate, UIGestureRecognizerDelegate {
    let model = API.sharedInstance
    var colorKeyboard: ColorKeyboardView?
    var canvas: CanvasView?
    var descriptionView: DescriptionInputView?
    var canvasCover = UIView()
    var underFingerView = UIImageView()
    var firstMember = User()
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let chevron = UIImage(named: "ChevronBack")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.tintColor = UIColor.whiteColor()
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        backButton.setImage(chevron, forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(DrawingViewController.unwind(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        let height = CGFloat(120)
        let canvasFrame = CGRect(x: 0.0, y: 108.0, width: self.view.frame.width, height: self.view.frame.width)
        let canvas = CanvasView(frame: canvasFrame, delagate: self, baseImage: UIImage.getImageWithColor(whiteColor, size: canvasFrame.size))
        self.canvas = canvas
        self.view.addSubview(canvas)
        
        canvasCover = UIView(frame: canvasFrame)
        canvasCover.backgroundColor = coverColor
        let canvasTap = UITapGestureRecognizer(target: self, action: #selector(NewThreadViewController.editCanvas(_:)))
        canvasTap.delegate = self
        canvasCover.addGestureRecognizer(canvasTap)
        let canvasSwipe = UIPanGestureRecognizer(target: self, action: #selector(NewThreadViewController.editCanvas(_:)))
        canvasSwipe.delegate = self
        canvasCover.addGestureRecognizer(canvasSwipe)
        canvasCover.hidden = false
        self.view.addSubview(canvasCover)

        let promptRect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 108)
        descriptionView = DescriptionInputView(frame: promptRect, cover: true, delagate: self, prompt: "Type something interesting...")
        self.view.addSubview(descriptionView!)
        
        let colorKeyboard = ColorKeyboardView(frame: CGRect(origin: CGPoint(x: CGFloat(0.0), y: canvas.frame.maxY), size: CGSize(width: self.view.frame.width, height: height)), delagate: self)
        self.view.addSubview(colorKeyboard)
        self.colorKeyboard = colorKeyboard
        
        let memberDisplay = UILabel(frame: CGRect(x: 8, y: 8, width: self.view.frame.width - 16, height: 12))
        memberDisplay.text = "→ " + self.firstMember.username
        memberDisplay.font = UIFont(name: "Arial", size: 10)
        memberDisplay.textColor = UIColor.lightGrayColor()
        memberDisplay.textAlignment = .Right
        self.view.addSubview(memberDisplay)
        
        self.underFingerView.frame = CGRect(x: self.view.frame.width - 106, y: 1, width: 106, height: 106)
        underFingerView.backgroundColor = UIColor.whiteColor()
        self.underFingerView.hidden = true
        self.view.addSubview(underFingerView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        descriptionView?.editPrompt(UIGestureRecognizer())
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if (!prefs.boolForKey("startRoundHowTo")) {
            let startRoundHowTo = UIAlertController(title: "Start a Chain", message: "Write a prompt or draw a picture below to start a chain", preferredStyle: UIAlertControllerStyle.Alert)
            startRoundHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(startRoundHowTo, animated: true, completion: nil)
            prefs.setValue(true, forKey: "startRoundHowTo")
        }
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        if (self.descriptionView!.hasKeyboard()) {
            if (self.descriptionView!.getDescriptionText().characters.count > 0 ) {
                let description = Content(author: User(), isDrawing: false, text: self.descriptionView!.getDescriptionText(), chainId: "", contentId: "")
                model.createChain(description, nextUser: firstMember)
                self.performSegueWithIdentifier("backToHome", sender: self)
            } else {
                let noPrompt = UIAlertController(title: "Write a prompt", message: "Write a prompt or draw a picture to send to \(firstMember.username)", preferredStyle: UIAlertControllerStyle.Alert)
                noPrompt.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(noPrompt, animated: true, completion: nil)
            }
        } else {
            let drawing = Content(author: User(), isDrawing: true, text: canvas!.getDrawing().toBase64(), chainId: "", contentId: "")
            model.createChain(drawing, nextUser: firstMember)
            self.performSegueWithIdentifier("backToHome", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "backToHome" {
            let prefs = NSUserDefaults.standardUserDefaults()
            if (!prefs.boolForKey("notificationsAskSet")) {
                prefs.setValue(true, forKey: "notificationsAsk")
                prefs.setValue(true, forKey: "notificationsAskSet")
            }
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
    
    
    func editCanvas(sender: UIGestureRecognizer) {
        canvasCover.hidden = true
        descriptionView!.hideKeyboard()
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if (!prefs.boolForKey("drawingHowTo")) {
            let drawingHowTo = UIAlertController(title: "Drawing", message: "Press color buttons to switch colors. Tap color buttons to MIX COLORS! The slider changes the brush size.", preferredStyle: UIAlertControllerStyle.Alert)
            drawingHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(drawingHowTo, animated: true, completion: nil)
            prefs.setValue(true, forKey: "drawingHowTo")
        }
    }
    
    func editDescription() {
        canvasCover.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.descriptionView!.hideKeyboard()
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
        self.performSegueWithIdentifier("backToChooseMember", sender: self)
    }
}
