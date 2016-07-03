//
//  DeleteActivity.swift
//  Canvix
//
//  Created by Dylan Wight on 6/7/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class DeleteActivity: UIActivity {
    
    let api = API.sharedInstance
    private var drawings = [Drawing]()
    
    override func activityType() -> String? {
        return "Delete"
    }
    
    override func activityTitle() -> String? {
        return "Delete"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "Delete Icon")
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
        for drawing in self.drawings {
//            self.api.deleteDrawing(drawing)
        }
    }
    
    override func activityViewController() -> UIViewController? {
        let deleteAlert = UIAlertController(title: "Delete drawing?", message: "This drawing will be deleted permanently", preferredStyle: UIAlertControllerStyle.Alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action: UIAlertAction!) in
            self.performActivity()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil ))

        
        return deleteAlert
    }

    override class func activityCategory() -> UIActivityCategory {
        return UIActivityCategory.Action
    }
}