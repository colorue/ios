//
//  Prompt.swift
//  Colorue
//
//  Created by Dylan Wight on 8/6/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import ObjectMapper

class HashTag: APIObject {
        
    public dynamic var text: String?
    var drawings = [Drawing]()
    
    
    override class func primaryKey() -> String? {
        return "text"
    }
    
    public override func mapping(map: Map) {
        text <- map["text"]
    }
}

