//
//  ColorKeyboardViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import FBSDKShareKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DrawingViewController: UIViewController, UIGestureRecognizerDelegate, ColorKeyboardDelagate, CanvasDelagate, UIPopoverPresentationControllerDelegate {
    
    var baseImage: UIImage?

    let api = API.sharedInstance
    let prefs = UserDefaults.standard

    var colorKeyboard: ColorKeyboardView?
    var canvas: CanvasView?
    var underFingerView = UIImageView()
    var keyboardCover = UIView()
    
    let backButton = UIButton(type: UIButtonType.custom)

    @IBOutlet weak var postButton: UIBarButtonItem!
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = R.image.logoInactive()
        let imageView = UIImageView(image:logo)
        imageView.tintColor = blackColor
        self.navigationItem.titleView = imageView

        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        let chevron = R.image.chevronDown()
        backButton.tintColor = blackColor
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        backButton.setImage(chevron, for: UIControlState())
        backButton.addTarget(self, action: #selector(DrawingViewController.unwind(_:)), for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        let keyboardHeight = self.view.frame.height / 5.55833333333333
        let canvasHeight = self.view.frame.height - keyboardHeight - 60
        
        let canvasFrame = CGRect(x:(self.view.frame.width - canvasHeight/1.3)/2, y: 0, width: canvasHeight/1.3, height: canvasHeight)
        
        
        if prefs.bool(forKey: Prefs.saved) {
            if baseImage == nil {
                if let savedDrawing = prefs.string(forKey: Prefs.savedDrawing) {
                    baseImage = UIImage.fromBase64(savedDrawing)
                }
            }
        }
        
        let canvas = CanvasView(frame: canvasFrame)
        canvas.delagate = self
        canvas.baseDrawing = baseImage
        
        self.view.addSubview(canvas)
        self.canvas = canvas
        
        let colorKeyboardFrame = CGRect(x: CGFloat(0.0), y: canvas.frame.maxY, width: self.view.frame.width, height: keyboardHeight)
        let colorKeyboard = ColorKeyboardView(frame: colorKeyboardFrame)
        colorKeyboard.delagate = self
        
        self.view.addSubview(colorKeyboard)
        self.colorKeyboard = colorKeyboard
        
        self.keyboardCover.frame = colorKeyboardFrame
        keyboardCover.backgroundColor = UIColor.black
        self.keyboardCover.alpha = 0.0
        self.view.addSubview(keyboardCover)
        

        self.underFingerView.frame = CGRect(x: canvas.frame.midX - (keyboardHeight/2), y: canvas.frame.maxY + 0.5, width: keyboardHeight, height: keyboardHeight)
        underFingerView.backgroundColor = UIColor.white
        self.underFingerView.alpha = 0.0
        self.view.addSubview(underFingerView)
        
        prefs.setValue(true, forKey: "saved")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (!prefs.bool(forKey: "drawingHowTo")) {
            let drawingHowTo = UIAlertController(title: "Welcome! Get Started Drawing", message: "Press color tabs to switch to their color, tap them to mix a bit of their color with your current color (Shown in the horizontal bar). Change your stroke size with the slider." , preferredStyle: UIAlertControllerStyle.alert)
            drawingHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(drawingHowTo, animated: true, completion: nil)
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
        
        let deleteAlert = UIAlertController(title: "Clear drawing?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            self.canvas!.trash()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    func setUnderfingerView(_ underFingerImage: UIImage) {
        self.colorKeyboard?.isUserInteractionEnabled = false
        if underFingerView.isHidden {
            underFingerView.isHidden = false
        }
        underFingerView.image = underFingerImage
    }
    
    func hideUnderFingerView() {
        self.colorKeyboard?.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.5,delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.underFingerView.alpha = 0.0
            self.keyboardCover.alpha = 0.0
            }, completion: nil)
    }
    
    func showUnderFingerView() {
        self.colorKeyboard?.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5,delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.underFingerView.alpha = 1.0
            self.keyboardCover.alpha = 0.5
        }, completion: nil)
    }
    
    func setColor(_ color: UIColor?) {
        guard let color = color else { return }
        self.colorKeyboard!.setColor(color)
    }
    
    func startPaintBucketSpinner() {
        colorKeyboard?.paintBucketButton.isHidden = true
        colorKeyboard?.paintBucketSpinner.startAnimating()
    }
    
    func stopPaintBucketSpinner() {
        colorKeyboard?.paintBucketSpinner.stopAnimating()
        colorKeyboard?.paintBucketButton.isHidden = false
    }
    
    func getKeyboardState() -> KeyboardToolState {
        return self.colorKeyboard?.state ?? .none
    }
    
    func setKeyboardState(_ state: KeyboardToolState) {
        colorKeyboard?.state = state
        colorKeyboard?.updateButtonColor()
    }
    
    func setDropperActive(_ active: Bool) {
        if active {
            if (!prefs.bool(forKey: "dropperHowTo")) {
                let dropperHowTo = UIAlertController(title: "Color Dropper Tool", message: "Tap on or drag to a color on the canvas to switch to it." , preferredStyle: UIAlertControllerStyle.alert)
                dropperHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(dropperHowTo, animated: true, completion: nil)
                prefs.setValue(true, forKey: "dropperHowTo")
            }
        }
        self.colorKeyboard?.state = .colorDropper
        self.colorKeyboard!.updateButtonColor()
    }
    
    func switchAlphaHowTo() {
        if (!prefs.bool(forKey: "alphaHowTo")) {
            let alphaHowTo = UIAlertController(title: "Opacity Rotator", message: "Tap this button to rotate through solid, sorta transparent, and mostly transparent lines.", preferredStyle: UIAlertControllerStyle.alert)
            alphaHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alphaHowTo, animated: true, completion: nil)
            prefs.setValue(true, forKey: "alphaHowTo")
        }
    }
    
    func postDrawing() {
        self.baseImage = nil
        self.postButton.isEnabled = false
        self.colorKeyboard!.uploading(0)
        self.view.isUserInteractionEnabled = false
        
        let newDrawing = Drawing(artist: User(), drawingId: "")
        newDrawing.setImage((canvas?.getDrawing())!)
        
        api.postDrawing(newDrawing, progressCallback: self.colorKeyboard!.uploading, finishedCallback: postCallback)
    }
    
    func postCallback(_ uploaded: Bool) {
        if uploaded {
            prefs.setValue(false, forKey: Prefs.saved)

            NotificationCenter.default.removeObserver(self)
            self.performSegue(withIdentifier: R.segue.drawingViewController.saveToHome, sender: self)
        } else {
            self.colorKeyboard!.uploadingFailed()
            self.view.isUserInteractionEnabled = true
            self.postButton.isEnabled = true
        }
    }
    
    func unwind(_ sender: UIBarButtonItem) {
        self.save()

        if (!prefs.bool(forKey: "firstCloseCanvas")) {
            let firstCloseCanvas = UIAlertController(title: "Close Canvas?", message: "Don't worry your drawing is saved" , preferredStyle: UIAlertControllerStyle.alert)
            firstCloseCanvas.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { alert in
                NotificationCenter.default.removeObserver(self)
                self.performSegue(withIdentifier: R.segue.drawingViewController.backToHome, sender: self)
            }))
            firstCloseCanvas.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

            self.present(firstCloseCanvas, animated: true, completion: nil)
            prefs.setValue(true, forKey: "firstCloseCanvas")
        } else {
            NotificationCenter.default.removeObserver(self)
            self.performSegue(withIdentifier: R.segue.drawingViewController.backToHome, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "saveToHome" {
            let targetController = segue.destination as? WallViewController
            if targetController?.tableView.numberOfRows(inSection: 1) > 0 {
                targetController?.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: UITableViewScrollPosition.top, animated: true)
            }
        } else if let dvc = segue.destination as? SharingViewController {
            
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.save()

        NotificationCenter.default.removeObserver(self)
    }
    
    func appMovedToBackground() {
        self.save()
        self.hideUnderFingerView()
    }
    
    fileprivate func save() {
        let color = self.colorKeyboard?.getCurrentColor()
        prefs.setValue(color?.coreImageColor!.red, forKey: Prefs.colorRed)
        prefs.setValue(color?.coreImageColor!.green, forKey: Prefs.colorGreen)
        prefs.setValue(color?.coreImageColor!.blue, forKey: Prefs.colorBlue)
        prefs.setValue(colorKeyboard?.getAlpha(), forKey: Prefs.colorAlpha)
        prefs.setValue(self.colorKeyboard?.getCurrentBrushSize(), forKey: Prefs.brushSize)
        prefs.setValue(self.canvas?.getDrawing().toBase64(), forKey: Prefs.savedDrawing)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverController: UIPopoverPresentationController) -> Bool  {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 1.0
            self.navigationController?.navigationBar.alpha = 1.0
        })
        return true
   }
}
