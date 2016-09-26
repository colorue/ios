//
//  Prompt.swift
//  Colorue
//
//  Created by Dylan Wight on 8/6/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class HashTag {
    let text: String
    var drawings = [Drawing]()
    
    let api = API.sharedInstance
    
    init(text: String) {
        self.text = text
    }
}

extension HashTag: Hashable {
    var hashValue: Int {
        return text.hashValue
    }
}

// MARK: Equatable
func == (lhs: HashTag, rhs: HashTag) -> Bool {
    return lhs.text == rhs.text
}
