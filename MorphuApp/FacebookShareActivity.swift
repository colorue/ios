//
//  DeleteActivity.swift
//  Canvix
//
//  Created by Dylan Wight on 6/7/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class FacebookShareActivity: UIActivity {
    
//    let fbActivity = UIActivity(UIActivityTypePostToFacebook)
    
    override func activityType() -> String? {
        return UIActivityTypePostToFacebook
    }
    
    override func activityTitle() -> String? {
        return "Facebook"
    }
    
    override func activityImage() -> UIImage? {
        return nil
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        
    }
    
    override func performActivity() {
        print("FacebookShareActivity")
    }
    
    override class func activityCategory() -> UIActivityCategory {
        return UIActivityCategory.Share
    }
}