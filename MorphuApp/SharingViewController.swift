//
//  SharingViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 7/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import FBSDKShareKit
import MessageUI
import Firebase

class SharingViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    let cornerRadius: CGFloat = 4.0
    
    var controller = MFMessageComposeViewController()
    
    var drawing: UIImage?
    var popoverController: DrawingViewController?
    
    let prefs = NSUserDefaults.standardUserDefaults()

    
    @IBOutlet weak var drawingImage: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.addTarget(self, action: #selector(SharingViewController.saveDrawing(_:)), forControlEvents: .TouchUpInside)
        }
    }

    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.addTarget(self, action: #selector(SharingViewController.sendDrawing(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var shareButton: UIButton! {
        didSet {
            shareButton.layer.cornerRadius = cornerRadius
            shareButton.addTarget(self, action: #selector(SharingViewController.shareToFacebook(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var postButton: UIButton! {
        didSet {
            postButton.layer.cornerRadius = cornerRadius
            postButton.addTarget(self, action: #selector(SharingViewController.postDrawing(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBAction func quitSharing(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: {
            self.popoverController!.view.alpha = 1.0
            self.popoverController!.navigationController?.navigationBar.alpha = 1.0
        })
        
        popoverController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        self.drawingImage.image = drawing
    }
    
    @objc private func shareToFacebook(sender: UIButton) {
        FIRAnalytics.logEventWithName("shareToFacebookClickedSharing", parameters: [:])

        let content = FBSDKSharePhotoContent()
        let photo = FBSDKSharePhoto(image: drawing, userGenerated: true)
        content.photos  = [photo]
        
        let dialog = FBSDKShareDialog()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = FBSDKShareDialogMode.Native
        if !dialog.show() {
            dialog.mode = FBSDKShareDialogMode.Automatic
            dialog.show()
        }
    }
    
    @objc private func saveDrawing(sender: UIButton) {
        if let drawing = drawing {
            UIImageWriteToSavedPhotosAlbum(drawing, self, nil, nil)
            FIRAnalytics.logEventWithName("savedDrawingFromSharing", parameters: [:])
            sender.enabled = false
        }
    }
    
    @objc private func sendDrawing(sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            if let image = drawing {
                controller.addAttachmentData(UIImagePNGRepresentation(image)!, typeIdentifier: "public.data", filename: "colorue.png")
            }
            controller.messageComposeDelegate = self
            self.resignFirstResponder()
            
            FIRAnalytics.logEventWithName("sendDrawingClickedSharing", parameters: [:])

            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func postDrawing(sender: UIButton) {
        FIRAnalytics.logEventWithName("postDrawing", parameters: [:])

        UIView.animateWithDuration(0.3, animations: {
            self.popoverController!.view.alpha = 1.0
            self.popoverController!.navigationController?.navigationBar.alpha = 1.0
       })
        
        popoverController!.dismissViewControllerAnimated(true, completion: nil)
        popoverController!.postDrawing()
    }
    
    
    // MARK: MFMessageComposeViewControllerDelegate Methods
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.controller = MFMessageComposeViewController()
    }
}
