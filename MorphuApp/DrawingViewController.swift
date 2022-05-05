//
//  ColorKeyboardViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Toast_Swift
import RealmSwift

class DrawingViewController: UIViewController, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate {

  let prefs = UserDefaults.standard

  private var drawing: Drawing? {
    let realm = try! Realm()
    return realm.object(ofType: Drawing.self, forPrimaryKey: drawingId)
  }

  var drawingId: String? {
    didSet {
      prefs.setValue(drawingId, forKey: "openDrawing")
      if let base64 = drawing?.base64 {
        baseImage = UIImage.fromBase64(base64)
      }
    }
  }
  
  var baseImage: UIImage?
  var notificationFeedback: UINotificationFeedbackGenerator? = nil
  var feedback: UISelectionFeedbackGenerator? = nil

  var colorKeyboard: ColorKeyboardView?
  var canvas: CanvasView?
  let underFingerView = UIImageView()
  let keyboardCover = UIView()
  let activeColorView = UIView()
  let drawButtonL = UIButton(type: UIButtonType.custom)
  let drawButtonR = UIButton(type: UIButtonType.custom)

  let undoButton = UIButton(type: .custom)
  let redoButton = UIButton(type: .custom)

  @IBOutlet weak var postButton: UIBarButtonItem!

  var aimDrawingOn = false

  //MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    
//    let logo = R.image.logoInactive()
//    let imageView = UIImageView(image:logo)
//    imageView.tintColor = Theme.black


//    let undoButton = UIButton(type: .custom)
//    undoButton.tintColor = .black
//    undoButton.setImage(UIImage(named: "arrow.uturn.backward.circle"), for: .normal)
//    self.navigationItem.titleView = undoButton


    let configuration = UIImage.SymbolConfiguration(pointSize: 20)

    undoButton.isEnabled = false
    undoButton.setImage(UIImage(systemName: "arrow.uturn.backward.circle", withConfiguration: configuration), for: .normal)
    undoButton.addTarget(self, action: #selector(DrawingViewController.undo), for: .touchUpInside)
    undoButton.tintColor = .black

    redoButton.isEnabled = false
    redoButton.setImage(UIImage(systemName: "arrow.uturn.forward.circle", withConfiguration: configuration), for: .normal)
    redoButton.addTarget(self, action: #selector(DrawingViewController.redo), for: .touchUpInside)
    redoButton.tintColor = .black

    let undoWrapper = UIStackView(arrangedSubviews: [undoButton, redoButton])
    undoWrapper.axis = .horizontal
    undoWrapper.spacing = 24.0
    self.navigationItem.titleView = undoWrapper

    self.navigationController?.navigationBar.backgroundColor = .white
    self.navigationController?.navigationBar.tintColor = .black
    navigationController?.navigationBar.setBottomBorderColor(color: Theme.divider, height: 0.5)
    
    
    NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    
    let keyboardHeight = self.view.frame.height / 5.55833333333333
    let canvasHeight = self.view.frame.height - keyboardHeight - 60
    
    let canvasFrame = CGRect(x:(self.view.frame.width - canvasHeight/1.3)/2, y: 60, width: canvasHeight/1.3, height: canvasHeight)
    
    let canvas = CanvasView(frame: canvasFrame)
    canvas.delegate = self
    canvas.baseDrawing = baseImage
    
    self.view.addSubview(canvas)
    self.canvas = canvas
    
    let colorKeyboardFrame = CGRect(x: CGFloat(0.0), y: canvas.frame.maxY, width: self.view.frame.width, height: keyboardHeight)
    let colorKeyboard = ColorKeyboardView(frame: colorKeyboardFrame)
    colorKeyboard.delegate = self
    
    self.view.addSubview(colorKeyboard)
    self.colorKeyboard = colorKeyboard



    self.keyboardCover.frame = colorKeyboardFrame
    self.keyboardCover.alpha = 0.0
    keyboardCover.backgroundColor = UIColor(patternImage: R.image.clearPattern()!)
    self.view.addSubview(keyboardCover)


    activeColorView.backgroundColor = colorKeyboard.getCurrentColor()
    activeColorView.alpha = colorKeyboard.getAlpha() ?? 1.0
    activeColorView.frame = CGRect(x: 0, y: 0, width: keyboardCover.frame.width, height: keyboardCover.frame.height)
    keyboardCover.addSubview(activeColorView)

    let separatorU = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0.5))
    separatorU.backgroundColor = Theme.divider
    keyboardCover.addSubview(separatorU)

    drawButtonL.frame = CGRect(x: keyboardHeight / 4.0, y: keyboardHeight / 4.0, width: keyboardHeight / 2.0, height: keyboardHeight / 2.0)
    drawButtonL.layer.cornerRadius = keyboardHeight / 4.0
    drawButtonL.backgroundColor = .white
    drawButtonL.isHidden = true
    keyboardCover.addSubview(drawButtonL)

    drawButtonR.frame = CGRect(x: view.frame.maxX - keyboardHeight / 4.0 - keyboardHeight / 2.0, y: keyboardHeight / 4.0, width: keyboardHeight / 2.0, height: keyboardHeight / 2.0)
    drawButtonR.layer.cornerRadius = keyboardHeight / 4.0
    drawButtonR.backgroundColor = .white
    drawButtonR.isHidden = true
    keyboardCover.addSubview(drawButtonR)

    let holdL = UILongPressGestureRecognizer(target: self, action: #selector(DrawingViewController.handleDrag(_:)))
    holdL.minimumPressDuration = 0.0
    holdL.delegate = self
    drawButtonL.addGestureRecognizer(holdL)

    let holdR = UILongPressGestureRecognizer(target: self, action: #selector(DrawingViewController.handleDrag(_:)))
    holdR.minimumPressDuration = 0.0
    holdR.delegate = self
    drawButtonR.addGestureRecognizer(holdR)

    underFingerView.frame = CGRect(x: canvas.frame.midX - (keyboardHeight/2), y: 0, width: keyboardHeight, height: keyboardHeight)
    underFingerView.backgroundColor = UIColor.white
    underFingerView.layer.borderWidth = 0.5
    underFingerView.layer.borderColor = Theme.divider.cgColor
    keyboardCover.addSubview(underFingerView)
    
    prefs.setValue(true, forKey: Prefs.saved)

    let duplicateAction =
    UIAction(title: NSLocalizedString("Duplicate", comment: ""),
             image: UIImage(systemName: "doc.on.doc")) { [weak self] action in
      self?.duplicateDrawing()
    }

    let shareAction =
    UIAction(title: NSLocalizedString("Share", comment: ""),
             image: UIImage(systemName: "square.and.arrow.up")) { [weak self] action in
      self?.shareDrawing()
    }

    let saveAction =
    UIAction(title: NSLocalizedString("Add to Photos", comment: ""),
             image: UIImage(systemName: "square.and.arrow.down")) { [weak self] action in
      guard let self = self, let drawing = self.canvas?.getDrawing() else { return }
      UIImageWriteToSavedPhotosAlbum(drawing, self, #selector(self.savedImage), nil)
      self.notificationFeedback = UINotificationFeedbackGenerator()
      self.notificationFeedback?.prepare()
    }
    let deleteAction =
    UIAction(title: NSLocalizedString("Delete", comment: ""),
             image: UIImage(systemName: "trash"),
             attributes: .destructive) { [weak self] action in
      self?.trash()
    }
    if #available(iOS 14.0, *) {
      postButton.menu = UIMenu(title: "", children: [duplicateAction, shareAction, saveAction, deleteAction])
      postButton.primaryAction = nil
    } else {
      postButton.target = self
      postButton.action = #selector(DrawingViewController.shareDrawing)
    }
  }

  @objc private func handleDrag(_ sender: UILongPressGestureRecognizer) {
    if (sender.state == .began) {
      feedback = UISelectionFeedbackGenerator()
      feedback?.selectionChanged()
      aimDrawingOn = true
    } else if (sender.state == .ended) {
      aimDrawingOn = false
      canvas?.completeCurve()
      feedback?.selectionChanged()
      feedback = nil
    }
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
  
  @objc func savedImage(_ im:UIImage, error:Error?, context:UnsafeMutableRawPointer?) {
    if let err = error {
      notificationFeedback?.notificationOccurred(.error)
      notificationFeedback = nil
      view.makeToast("Error saving drawing", position: .center)
      print(err)
      return
    }
    notificationFeedback?.notificationOccurred(.success)
    view.makeToast("Saved to Photos", position: .center)
    notificationFeedback = nil
    AppStoreReviewManager.requestReviewIfAppropriate()
  }

  func duplicateDrawing () {
    guard let image = canvas?.getDrawing() else { return }
    notificationFeedback = UINotificationFeedbackGenerator()
    notificationFeedback?.prepare()
    let realm = try! Realm()
    let drawingDuplicate = Drawing()
    drawingDuplicate.base64 = image.toBase64()
    try! realm.write {
      realm.add(drawingDuplicate)
    }
    view.makeToast("Duplicated Drawing", position: .center)
    notificationFeedback?.notificationOccurred(.success)
    notificationFeedback = nil
  }
  
  @objc func shareDrawing () {
    guard let drawing = canvas?.getDrawing() else { return }
    
    let activityViewController: UIActivityViewController = UIActivityViewController(
      activityItems: [drawing], applicationActivities: nil)
    
    // This lines is for the popover you need to show in iPad
    activityViewController.popoverPresentationController?.barButtonItem = postButton
    activityViewController.popoverPresentationController?.sourceView = UIApplication.shared.windows.first
    
    // This line remove the arrow of the popover to show in iPad
    activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
    
    // Pre-configuring activity items
    activityViewController.activityItemsConfiguration = [
      UIActivity.ActivityType.message,
      UIActivity.ActivityType.postToFacebook,
      UIActivity.ActivityType.postToTwitter,
    ] as? UIActivityItemsConfigurationReading
    
    // Anything you want to exclude
    activityViewController.excludedActivityTypes = [
      UIActivity.ActivityType.postToWeibo,
      UIActivity.ActivityType.print,
      UIActivity.ActivityType.addToReadingList,
      UIActivity.ActivityType.postToFlickr,
      UIActivity.ActivityType.postToVimeo,
      UIActivity.ActivityType.postToTencentWeibo,
      UIActivity.ActivityType.airDrop
    ]
    
    activityViewController.isModalInPresentation = true
    self.present(activityViewController, animated: true, completion: nil)
    activityViewController.completionWithItemsHandler = { activityType, completed, items, error in
      guard completed else { return }
      AppStoreReviewManager.requestReviewIfAppropriate()
    }
  }
  
  func setDropperActive(_ active: Bool) {
//    if active {
//      if (!prefs.bool(forKey: "dropperHowTo")) {
//        let dropperHowTo = UIAlertController(title: "Color Dropper Tool", message: "Tap on or drag to a color on the canvas to switch to it." , preferredStyle: UIAlertControllerStyle.alert)
//        dropperHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//        self.present(dropperHowTo, animated: true, completion: nil)
//        prefs.setValue(true, forKey: "dropperHowTo")
//      }
//    }
    self.colorKeyboard?.state = .colorDropper
    self.colorKeyboard!.updateButtonColor()
  }
  
//  @objc func unwind(_ sender: UIBarButtonItem) {
//    self.saveDrawing()
//
//    if (!prefs.bool(forKey: "firstCloseCanvas")) {
//      let firstCloseCanvas = UIAlertController(title: "Close Canvas?", message: "Don't worry your drawing is saved" , preferredStyle: UIAlertControllerStyle.alert)
//      firstCloseCanvas.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { alert in
//        NotificationCenter.default.removeObserver(self)
//        self.performSegue(withIdentifier: R.segue.drawingViewController.backToHome, sender: self)
//      }))
//      firstCloseCanvas.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
//
//      self.present(firstCloseCanvas, animated: true, completion: nil)
//      prefs.setValue(true, forKey: "firstCloseCanvas")
//    } else {
//      NotificationCenter.default.removeObserver(self)
//      self.performSegue(withIdentifier: R.segue.drawingViewController.backToHome, sender: self)
//    }
//  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.saveDrawing()
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func appMovedToBackground() {
    self.saveDrawing()
    self.hideUnderFingerView()
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

extension DrawingViewController: ColorKeyboardDelegate {

  func setColor (_ color: UIColor, secondary: UIColor, alpha: CGFloat) {
    UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: { [weak self] in
      self?.activeColorView.backgroundColor = color
      self?.activeColorView.alpha = alpha
      self?.drawButtonL.backgroundColor = secondary
      self?.drawButtonR.backgroundColor = secondary
    }, completion: nil)
  }
  
  func trash() {
    let deleteAlert = UIAlertController(title: "Are you want to delete this drawing?", message: nil, preferredStyle: UIAlertControllerStyle.preferActionSheet)
    
    deleteAlert.addAction(UIAlertAction(title: "Delete Drawing", style: .destructive, handler: { [weak self] (action: UIAlertAction!) in
      self?.canvas!.trash()
      guard let self = self, let drawing = self.drawing else { return }
      self.notificationFeedback = UINotificationFeedbackGenerator()
      self.notificationFeedback?.prepare()
      let realm = try! Realm()
      try! realm.write {
        realm.delete(drawing)
      }
      self.drawingId = nil
      self.notificationFeedback?.notificationOccurred(.success)
      self.notificationFeedback = nil
    }))
    
    deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
    self.present(deleteAlert, animated: true, completion: nil)
  }
  
  @objc func undo() {
    self.canvas!.undo()
    feedback = UISelectionFeedbackGenerator()
    feedback?.selectionChanged()
    feedback = nil
  }
  
  @objc func redo() {
    self.canvas!.redo()
    feedback = UISelectionFeedbackGenerator()
    feedback?.selectionChanged()
    feedback = nil
  }
}

extension DrawingViewController: CanvasDelegate {
  func saveDrawing() {
    DispatchQueue.main.async { [weak self] in
      guard  let self = self, let canvas = self.canvas, !canvas.isEmpty else { return }
      let realm = try! Realm()

      if let drawing = self.drawing {
        try! realm.write {
          drawing.base64 = canvas.getDrawing().toBase64()
          drawing.updatedAt = Date().timeIntervalSince1970
        }
      } else {
        let drawing = Drawing()
        drawing.base64 = canvas.getDrawing().toBase64()
        self.drawingId = drawing.id
        try! realm.write {
          realm.add(drawing)
        }
      }
    }
  }

  func updateUndoButtons(undo: Bool, redo: Bool) {
    DispatchQueue.main.async { [weak self] in
      self?.undoButton.isEnabled = undo
      self?.redoButton.isEnabled = redo
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

  func setUnderfingerView(_ underFingerImage: UIImage) {
    self.colorKeyboard?.isUserInteractionEnabled = false
    if underFingerView.isHidden {
      underFingerView.isHidden = false
    }
    underFingerView.image = underFingerImage
  }

  func hideUnderFingerView() {
    self.colorKeyboard?.isUserInteractionEnabled = true
    UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
      self.keyboardCover.alpha = 0.0
    }, completion: nil)
  }

  func showUnderFingerView() {
    self.colorKeyboard?.isUserInteractionEnabled = false
    UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: { [weak self] in
      self?.keyboardCover.alpha = 1.0
      let isBullsEye = self?.colorKeyboard?.state == .bullsEye
      self?.drawButtonL.isHidden = !isBullsEye
      self?.drawButtonR.isHidden = !isBullsEye
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

  func isDrawingOn() -> Bool {
    return aimDrawingOn
  }
}
