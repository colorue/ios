//
//  ShareViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 6/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import FBSDKShareKit

class ShareViewController: UIViewController {
    var drawingInstance: Drawing?
    var button: FBSDKShareButton =  FBSDKShareButton()
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = drawingInstance?.getImage()
        
        let photo = FBSDKSharePhoto(image: drawingInstance!.getImage(), userGenerated: true)
        let content = FBSDKSharePhotoContent()
        content.photos  = [photo]
        content.contentURL = NSURL(string: "https://fb.me/1236351319728544")
        
        button.shareContent = content

        button.center = view.center
        self.view.addSubview(button)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func facebookButton(sender: UIButton) {

        
    }
}
