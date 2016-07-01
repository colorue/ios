//
//  SharingViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 7/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import FBSDKShareKit

class SharingViewController: UIViewController {
    
    @IBOutlet weak var drawingImage: UIImageView!
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var photosLabel: UILabel!
    @IBOutlet weak var photosSwitch: UISwitch!
    
    @IBOutlet weak var facebookLabel: UILabel!
    @IBOutlet weak var facebookSwitch: UISwitch!
    
    var drawing: UIImage?
    var popoverController: DrawingViewController?
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        self.drawingImage.image = drawing
        self.popoverPresentationController?.backgroundColor = blackColor
        
        photosSwitch.addTarget(self, action: #selector(SharingViewController.switchChanged(_:)), forControlEvents: .ValueChanged)
        facebookSwitch.addTarget(self, action: #selector(SharingViewController.switchChanged(_:)), forControlEvents: .ValueChanged)
        
        photosSwitch.on = prefs.boolForKey("saveToPhotos")
//        facebookSwitch.on = prefs.boolForKey("postToFacebook")
        
        switchChanged(photosSwitch)
//        switchChanged(facebookSwitch)
    }
    
    func switchChanged(sender: UISwitch) {
        if sender == photosSwitch {
            if sender.on {
                photosLabel.textColor = UIColor.blackColor()
            } else {
                photosLabel.textColor = UIColor.lightGrayColor()
            }
            prefs.setValue(sender.on, forKey: "saveToPhotos")
        } else if sender == facebookSwitch {
            if sender.on {
                facebookLabel.textColor = UIColor.blackColor()
                postToFacebook()
            } else {
                facebookLabel.textColor = UIColor.lightGrayColor()
            }
//            prefs.setValue(sender.on, forKey: "postToFacebook")
        }
    }
    
    private func postToFacebook() {
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
    
    @IBAction func post(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: {
            self.popoverController!.view.alpha = 1.0
            self.popoverController!.navigationController?.navigationBar.alpha = 1.0
       })
        
        popoverController!.dismissViewControllerAnimated(true, completion: nil)
        popoverController!.postDrawing(photosSwitch.on, postToFacebook: facebookSwitch.on)
    }
}
