//
//  DescribingViewController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/11/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class DescribingViewController: UIViewController, UIGestureRecognizerDelegate, DescriptionInputDelagate {
    let model = API.sharedInstance
    var drawingInstance: Content?
    var descriptionView: DescriptionInputView?
    var chainInstance = Chain()
    var nextUser = User()
    var finishChain = false

    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var actionIcon: UIImageView!
    @IBOutlet weak var drawingImage: UIImageView!
    @IBOutlet weak var timeCreated: UILabel!
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let chevron = UIImage(named: "ChevronBack")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.tintColor = UIColor.whiteColor()
        backButton.frame = CGRect(x: 0.0, y: 0.0, width: 22, height: 22)
        backButton.setImage(chevron, forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(DescribingViewController.unwind(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        creator.text = drawingInstance!.getAuthor().username
        //descriptionCell.actionIcon.image = self.stackIcon
        drawingImage.image = UIImage.fromBase64(drawingInstance!.text)
        timeCreated.text = drawingInstance!.getTimeSinceSent()
        
        let drawingClick = UIView(frame: CGRect(x: 0, y: 110, width: self.view.frame.width, height: self.view.frame.height - 110))
        drawingClick.backgroundColor = UIColor.clearColor()
        let promptTap = UITapGestureRecognizer(target: self, action: #selector(DescribingViewController.dismissKeyboard(_:)))
        promptTap.delegate = self
        drawingClick.addGestureRecognizer(promptTap)
        self.view.addSubview(drawingClick)
        
        descriptionView = DescriptionInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 110), cover: false, delagate: self)
        self.view.addSubview(descriptionView!)
    }
    
    func dismissKeyboard(sender: UIGestureRecognizer) {
        descriptionView!.hideKeyboard()
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        if (self.descriptionView!.getDescriptionText().characters.count > 0 ) {
            let newDescription = Content(author: User(), isDrawing: false, text: (descriptionView?.getDescriptionText())!, chainId: "", contentId: "")
            if self.finishChain {
                model.finishChain(chainInstance, content: newDescription)
            } else {
                model.addToChain(chainInstance, content: newDescription, nextUser: nextUser)
            }
            self.performSegueWithIdentifier("unwindToInbox", sender: self)
        } else {
            let noPrompt = UIAlertController(title: "Describe this drawing", message: "Describe \(creator.text!)'s drawing to continue the round", preferredStyle: UIAlertControllerStyle.Alert)
            noPrompt.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(noPrompt, animated: true, completion: nil)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        descriptionView!.hideKeyboard()
    }
    
    func unwind(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("backToPickNext", sender: self)
    }
    
    func editDescription() {
        print("editDescription")
    }
}