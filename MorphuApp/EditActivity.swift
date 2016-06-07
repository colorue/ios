//
//  DeleteActivity.swift
//  Canvix
//
//  Created by Dylan Wight on 6/7/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class EditActivity: UIActivity {
    
    let api = API.sharedInstance
    private var drawings = [Drawing]()
    
    override func activityType() -> String? {
        return "Edit"
    }
    
    override func activityTitle() -> String? {
        return "Edit"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "Edit Icon")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        for activityItem in activityItems {
            if activityItem is Drawing {
                return true
            }
        }
        return false
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for activityItem in activityItems {
            if let drawing = activityItem as? Drawing {
                self.drawings.append(drawing)
            }
        }
    }
    
    override func performActivity() {
        
    }
    
    override func activityViewController() -> UIViewController? {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let activity = storyboard.instantiateViewControllerWithIdentifier("DrawingViewController") as! UINavigationController
        let drawingViewController = activity.topViewController as! DrawingViewController
        
    
        drawingViewController.baseImage = drawings.first!.getImage()
        
        return activity
    }
    
    override class func activityCategory() -> UIActivityCategory {
        return UIActivityCategory.Action
    }
}