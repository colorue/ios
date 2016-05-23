//
//  Drawing.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class Drawing {
    
    let model = API.sharedInstance
    let text: String
    let timeSent: NSDate
    private var drawingId: String
    private var artist: User
    
    init(artist: User, timeSent: NSDate = NSDate(), text: String, drawingId: String) {
        self.artist = artist
        self.timeSent = timeSent
        self.text = text
        self.drawingId = drawingId
    }
    
    convenience init() {
        self.init(artist: User(), timeSent: NSDate(), text: "", drawingId: "")
    }
    
    func setDrawingId(drawingId: String) {
        self.drawingId = drawingId
    }
    
    func getDrawingId() -> String {
        return self.drawingId
    }
    
    func setArtist(artist: User) {
        self.artist = artist
    }
    
    func getArtist() -> User {
        return self.artist
    }
    
    func getTimeSinceSent() -> String {
        let secondsSince = NSDate().timeIntervalSinceDate(self.timeSent)
        switch(secondsSince) {
        case 0..<60:
            return "now"
        case 60..<3600:
            return String(Int(secondsSince/60))  + "m"
        case 3600..<3600*24:
            return String(Int(secondsSince/3600)) + "h"
        default:
            return String(Int(secondsSince/(3600 * 24))) + "d"
        }
    }
    
    func toAnyObject()-> NSDictionary {
        return ["artist": self.artist.userId,
                "text": self.text,
                "timeSent": model.dateFormatter.stringFromDate(self.timeSent)]
    }
}
