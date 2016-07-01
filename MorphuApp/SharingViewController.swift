//
//  SharingViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 7/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class SharingViewController: UIViewController {
    @IBOutlet weak var drawingImage: UIImageView!
    @IBOutlet weak var facebookSwitch: UISwitch!
    @IBOutlet weak var postButton: UIButton!
    
    var drawing: UIImage?
    var popoverController: UIViewController?
    
    override func viewDidLoad() {
        self.drawingImage.image = drawing
        self.popoverPresentationController?.backgroundColor = blackColor
    }
    
    @IBAction func post(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: {
            self.popoverController!.view.alpha = 1.0
            self.popoverController!.navigationController?.navigationBar.alpha = 1.0
       })
        popoverController!.dismissViewControllerAnimated(true, completion: nil)
    }
}
