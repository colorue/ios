//
//  Analytics.swift
//  Colorue
//
//  Created by Dylan Wight on 8/7/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Firebase

enum AnalyticsEvents: String {
    case deletedComment = "Deleted Comment"
    case reportedComment = "Reported Comment"
    case wroteComment = "Wrote Comment"
    case likedDrawing = "Liked Drawing"
    case unlikedDrawing = "Unliked Drawing"
    case sendDrawing = "Send Drawing"
    case postToFacebook = "Post to Facebook"
}

struct Analytics {
    static func logEvent(event: AnalyticsEvents, parameters: [String : NSObject] = [:]) {
        FIRAnalytics.logEventWithName(event.rawValue, parameters: parameters)
    }
}

