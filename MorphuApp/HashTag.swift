//
//  Prompt.swift
//  Colorue
//
//  Created by Dylan Wight on 8/6/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

class HashTag {
        
    let text: String
    let timeStamp: Double
    private var drawingSet = Set<Drawing>()
    
    var drawings: [Drawing] {
        return drawingSet.sorted(by: { $0.timeStamp > $1.timeStamp })
    }
    
    var displayText: String {
        return "#\(text)"
    }
    
    init(text: String = "", timeStamp: Double = 0 - Date().timeIntervalSince1970) {
        self.text = text
        self.timeStamp = timeStamp
    }
    
    func add(drawing: Drawing) {
        drawingSet.insert(drawing)
    }
    
    func remove(drawing: Drawing) {
        drawingSet.remove(drawing)
    }
    
    func toAnyObject() -> NSDictionary {
        return ["text": self.text,
                "timeStamp": self.timeStamp]
    }
}
