//
//  Prompt.swift
//  Colorue
//
//  Created by Dylan Wight on 8/6/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

class HashTag {
        
    public dynamic var text: String?
    var drawings = [Drawing]()
    
    
    class func primaryKey() -> String? {
        return "text"
    }
}

