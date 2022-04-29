//
//  Drawing.swift
//  Colorue
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class Drawing {

    var id: String
    var timeStamp: Double
    var userId: String
    var image = UIImage()
    var imageUrl: URL?

    init(userId: String, timeStamp: Double = 0 - Date().timeIntervalSince1970, id: String = "", caption: String = "") {
        self.userId = userId
        self.timeStamp = timeStamp
        self.id = id
    }

    func toAnyObject()-> NSDictionary {
        return ["artist": self.userId,
                "timeStamp": self.timeStamp,
                "url": self.imageUrl?.absoluteString ?? ""]
    }
}

extension Drawing: Hashable {
    var hashValue: Int {
        return id.hashValue
    }
}

// MARK: Equatable
func == (lhs: Drawing, rhs: Drawing) -> Bool {
    return lhs.id == rhs.id
}
