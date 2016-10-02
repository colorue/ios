//
//  Timestamp.swift
//  Colorue
//
//  Created by Dylan Wight on 10/2/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation


/**
 Object ID type
 */
public typealias TimeStamp = Double

extension TimeStamp {
    
    var timeSince: String {
        let secondsSince =  Date().timeIntervalSince1970 + self
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
}
