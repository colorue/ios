//
//  DeleteActivity.swift
//  Canvix
//
//  Created by Dylan Wight on 6/7/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class ProfilePicActivity: UIActivity {
    
    let api = API.sharedInstance
    private var drawings = [Drawing]()
    
    override func activityType() -> String? {
        return "ProfilePicActivity"
    }
    
    override func activityTitle() -> String? {
        return "Make profile picture"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "Profile Icon")
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
            self.api.makeProfilePic(drawing)
        }
    }
    
    override class func activityCategory() -> UIActivityCategory {
        return UIActivityCategory.Action
    }
}