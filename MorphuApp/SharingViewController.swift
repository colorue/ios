//
//  SharingViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 7/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import MessageUI

class SharingViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    let cornerRadius: CGFloat = 4.0
    
    var drawing: UIImage?
    var popoverController: DrawingViewController?
    
    let prefs = UserDefaults.standard

    
    @IBOutlet weak var drawingImage: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.addTarget(self, action: #selector(SharingViewController.saveDrawing(_:)), for: .touchUpInside)
        }
    }

    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.addTarget(self, action: #selector(SharingViewController.sendDrawing(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var shareButton: UIButton! {
        didSet {
            shareButton.layer.cornerRadius = cornerRadius
            shareButton.addTarget(self, action: #selector(SharingViewController.shareToFacebook(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var postButton: UIButton! {
        didSet {
            postButton.layer.cornerRadius = cornerRadius
            postButton.addTarget(self, action: #selector(SharingViewController.postDrawing(_:)), for: .touchUpInside)
        }
    }
    
    @IBAction func quitSharing(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.popoverController!.view.alpha = 1.0
            self.popoverController!.navigationController?.navigationBar.alpha = 1.0
        })
        
        popoverController!.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var textField: UITextField? {
        didSet {
            textField?.delegate = self
            textField?.font = R.font.openSans(size: 12.0)
            textField?.returnKeyType = .done
            textField?.autocapitalizationType = .sentences
        }
    }
    
    override func viewDidLoad() {
        self.drawingImage.image = drawing
    }
    
    @objc fileprivate func shareToFacebook(_ sender: UIButton) {
//        FIRAnalytics.logEvent(withName: "shareToFacebookClickedSharing", parameters: [:])
//
//        let content = FBSDKSharePhotoContent()
//        let photo = FBSDKSharePhoto(image: drawing, userGenerated: true)
//        content.photos  = [photo]
//
//        let dialog = FBSDKShareDialog()
//        dialog.fromViewController = self
//        dialog.shareContent = content
//        dialog.mode = FBSDKShareDialogMode.native
//        if !dialog.show() {
//            dialog.mode = FBSDKShareDialogMode.automatic
//            dialog.show()
//        }
    }
    
    @objc fileprivate func saveDrawing(_ sender: UIButton) {
        if let drawing = drawing {
            UIImageWriteToSavedPhotosAlbum(drawing, self, nil, nil)
            sender.isEnabled = false
        }
    }
    
    @objc fileprivate func sendDrawing(_ sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            
            let controller = MFMessageComposeViewController()

            if let image = drawing {
                controller.addAttachmentData(UIImagePNGRepresentation(image)!, typeIdentifier: "public.data", filename: "colorue.png")
            }
            controller.messageComposeDelegate = self
            self.resignFirstResponder()
            self.present(controller, animated: true, completion: nil)
        }
    }
    
  @objc func postDrawing(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.popoverController?.view.alpha = 1.0
            self.popoverController?.navigationController?.navigationBar.alpha = 1.0
        })
        
        popoverController?.dismiss(animated: true, completion: nil)
        popoverController?.postDrawing(caption: textField?.text ?? "")
    }
    
    
    // MARK: MFMessageComposeViewControllerDelegate Methods
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SharingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
