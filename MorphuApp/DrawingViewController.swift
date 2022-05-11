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
import AVFoundation

class DrawingViewController: UIViewController, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate {

  let prefs = UserDefaults.standard

  private var drawing: Drawing? {
    guard let drawingId = drawingId else { return nil }
    let realm = try! Realm()
    return realm.object(ofType: Drawing.self, forPrimaryKey: drawingId)
  }

  var tool: ToolbarButton?

  var drawingId: String? {
    didSet {
      if let drawingId = drawingId {
        prefs.setValue(drawingId, forKey: "openDrawing")
        if let base64 = drawing?.base64 {
          baseImage = UIImage.fromBase64(base64)
        }
      } else {
        canvas?.trash()
      }
    }
  }
  
  var baseImage: UIImage?

  var colorKeyboard: ColorKeyboardView?
  var canvas: CanvasView?
  let underFingerView = UIImageView()
  let keyboardCover = UIView()
  let activeColorView = UIView()
  let drawButtonL = UIButton(type: UIButton.ButtonType.custom)
  let drawButtonR = UIButton(type: UIButton.ButtonType.custom)

  let undoButton = UIButton(type: .custom)
  let redoButton = UIButton(type: .custom)

  fileprivate var imagePicker = UIImagePickerController()

  @IBOutlet weak var postButton: UIBarButtonItem!

  //MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    becomeFirstResponder() // To get shake gesture

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
    
    
    NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    
    let keyboardHeight = self.view.frame.height / 5.55833333333333
    let canvasHeight = self.view.frame.height - keyboardHeight - 60
    
    let canvasFrame = CGRect(x: 0, y: 60, width: view.frame.width, height: canvasHeight)
    
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


    activeColorView.backgroundColor = colorKeyboard.color
    activeColorView.alpha = colorKeyboard.alpha
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

    let holdL = UILongPressGestureRecognizer(target: self, action: #selector(DrawingViewController.onDrag(_:)))
    holdL.minimumPressDuration = 0.0
    holdL.delegate = self
    drawButtonL.addGestureRecognizer(holdL)
//    drawButtonL.actions(forTarget: #selector(DrawingViewController.onTap(_:)), forControlEvent: .touchDown)

    let holdR = UILongPressGestureRecognizer(target: self, action: #selector(DrawingViewController.onDrag(_:)))
    holdR.minimumPressDuration = 0.0
    holdR.delegate = self
    drawButtonR.addGestureRecognizer(holdR)
//    drawButtonR.actions(forTarget: #selector(DrawingViewController.onTap(_:)), forControlEvent: .touchDown)

    underFingerView.frame = CGRect(x: canvas.frame.midX - (keyboardHeight/2), y: 0, width: keyboardHeight, height: keyboardHeight)
    underFingerView.backgroundColor = UIColor.white
    underFingerView.layer.borderWidth = 0.5
    underFingerView.layer.borderColor = Theme.divider.cgColor
    keyboardCover.addSubview(underFingerView)
    
    prefs.setValue(true, forKey: Prefs.saved)


    let newAction =
    UIAction(title: NSLocalizedString("New Drawing", comment: ""),
             image: UIImage(systemName: "square.and.pencil")) { [weak self] action in
      self?.newDrawing()
    }

    let duplicateAction =
    UIAction(title: NSLocalizedString("Duplicate", comment: ""),
             image: UIImage(systemName: "plus.square.on.square")) { [weak self] action in
      self?.duplicateDrawing()
    }

    let importImageAction =
    UIAction(title: NSLocalizedString("Import Image", comment: ""),
             image: UIImage(systemName: "photo")) { [weak self] action in
      self?.importImage()
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
    }
    let deleteAction =
    UIAction(title: NSLocalizedString("Delete", comment: ""),
             image: UIImage(systemName: "trash"),
             attributes: .destructive) { [weak self] action in
      self?.trash()
    }
    if #available(iOS 14.0, *) {
      postButton.menu = UIMenu(title: "", children: [newAction, duplicateAction, importImageAction, shareAction, saveAction, deleteAction])
      postButton.primaryAction = nil
    } else {
      postButton.target = self
      postButton.action = #selector(DrawingViewController.shareDrawing)
    }
  }

  @objc private func onDrag(_ sender: UILongPressGestureRecognizer) {
    if (sender.state == .began) {
      canvas?.drawingStroke?.onPress()
    } else if (sender.state == .ended) {
      canvas?.drawingStroke?.onRelease()
    }
  }

  func trash() {
    let deleteAlert = UIAlertController(title: "Are you want to delete this drawing?", message: nil, preferredStyle: UIAlertController.Style.preferActionSheet)

    deleteAlert.addAction(UIAlertAction(title: "Delete Drawing", style: .destructive, handler: { [weak self] (action: UIAlertAction!) in
      self?.canvas!.trash()
      guard let self = self, let drawing = self.drawing else { return }
      let realm = try! Realm()
      try! realm.write {
        realm.delete(drawing)
      }
      self.drawingId = nil
      Haptic.notificationOccurred(.success)
    }))

    deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
    self.present(deleteAlert, animated: true, completion: nil)
  }

  @objc func undo() {
    self.canvas?.undo()
    Haptic.selectionChanged()
  }

  @objc func redo() {
    self.canvas?.redo()
    Haptic.selectionChanged()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if (!prefs.bool(forKey: "drawingHowTo")) {
      let drawingHowTo = UIAlertController(title: "Welcome! Get Started Drawing", message: "Press color tabs to switch to their color, tap them to mix a bit of their color with your current color (Shown in the horizontal bar). Change your stroke size with the slider." , preferredStyle: UIAlertController.Style.alert)
      drawingHowTo.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
      self.present(drawingHowTo, animated: true, completion: nil)
      prefs.setValue(true, forKey: "drawingHowTo")
    }
  }
  
  @objc func savedImage(_ im:UIImage, error:Error?, context:UnsafeMutableRawPointer?) {
    if let err = error {
      Haptic.notificationOccurred(.error)
      view.makeToast("Error saving drawing", position: .center)
      print(err)
      return
    }
    Haptic.notificationOccurred(.success)
    view.makeToast("Saved to Photos", position: .center)
    AppStoreReviewManager.requestReviewIfAppropriate()
  }

  func newDrawing () {
    guard let _ = drawingId else { return }
    self.drawingId = nil
    view.makeToast("Drawing Saved", position: .center)
    Haptic.notificationOccurred(.success)
  }

  func duplicateDrawing () {
    guard let image = canvas?.getDrawing() else { return }
    let realm = try! Realm()
    let drawingDuplicate = Drawing()
    drawingDuplicate.base64 = image.toBase64()
    try! realm.write {
      realm.add(drawingDuplicate)
    }
    view.makeToast("Duplicated Drawing", position: .center)
    Haptic.notificationOccurred(.success)
  }

  func importImage () {
    guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    else {
      guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
      UIApplication.shared.open(url)
      return
    }

    imagePicker.allowsEditing = false
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    self.present(imagePicker, animated: true, completion: nil)
  }

  
  @objc func shareDrawing () {
    guard let drawing = canvas?.getDrawing(),
          let data = drawing.pngData()
    else { return }

    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let filename = paths[0].appendingPathComponent("Colorue.png")
    try? data.write(to: filename)

    
    let activityViewController: UIActivityViewController = UIActivityViewController(
      activityItems: [filename], applicationActivities: nil)
    
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
    UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: { [weak self] in
      self?.activeColorView.backgroundColor = color
      self?.activeColorView.alpha = alpha
      self?.drawButtonL.backgroundColor = secondary
      self?.drawButtonR.backgroundColor = secondary
    }, completion: nil)
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
    return colorKeyboard?.color ?? .black
  }

  func getCurrentBrushSize() -> Float {
    return colorKeyboard?.brushSize ?? 0
  }

  func getAlpha() -> CGFloat? {
    return colorKeyboard?.opacity
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
    UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
      self.keyboardCover.alpha = 0.0
    }, completion: nil)
  }

  func showUnderFingerView() {
    self.colorKeyboard?.isUserInteractionEnabled = false
    UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: { [weak self] in
      self?.keyboardCover.alpha = 1.0
      let showDrawButtons = self?.colorKeyboard?.tool?.usesAimButtons ?? false
      self?.drawButtonL.isHidden = !showDrawButtons
      self?.drawButtonR.isHidden = !showDrawButtons
    }, completion: nil)
  }

  // Used by dropper
  func setColor(_ color: UIColor?) {
    guard let color = color else { return }
    UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: { [weak self] in
      self?.colorKeyboard?.color = color
      self?.colorKeyboard?.opacity = 1.0
      self?.colorKeyboard?.tool = nil
    })
  }

  func getKeyboardTool() -> ToolbarButton? {
    return self.colorKeyboard?.tool
  }
}

// MARK: -  UIImagePickerControllerDelegate
extension DrawingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      canvas?.baseDrawing = pickedImage
      Haptic.notificationOccurred(.success)
    }

    imagePicker.dismiss(animated: true, completion: nil)
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: -  ShakeGestureRegognizer
extension DrawingViewController {
  override var canBecomeFirstResponder: Bool {
    get {
      return true
    }
  }

  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      guard undoButton.isEnabled || redoButton.isEnabled else { return }
      Haptic.notificationOccurred(.success)
      let title = undoButton.isEnabled ? "Undo added stroke" : "Redo added stroke"
      let undoAlert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)

      if (undoButton.isEnabled) {
        undoAlert.addAction(UIAlertAction(title: "Undo", style: .default, handler: { [weak self] (action: UIAlertAction!) in
          self?.canvas!.undo()
        }))
      }

      if (redoButton.isEnabled) {
        let redoTitle = undoButton.isEnabled ? "Redo added stroke" : "Redo"
        undoAlert.addAction(UIAlertAction(title: redoTitle, style: .default, handler: { [weak self] (action: UIAlertAction!) in
          self?.canvas!.redo()
        }))
      }

      undoAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
      self.present(undoAlert, animated: true, completion: nil)
    }
  }
}
