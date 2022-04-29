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
    var url: String
    var createdAt: Double

    init( id: String, url: String, createdAt: Double) {
      self.id = id
      self.url = url
      self.createdAt = createdAt
    }

    func toAnyObject()-> NSDictionary {
        return ["id": self.id,
                "createdAt": self.createdAt,
                "url": self.url]
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
