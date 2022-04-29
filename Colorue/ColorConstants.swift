//
//  ColorConstants.swift
//  Colorue
//
//  Created by Dylan Wight on 4/9/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

struct Theme {
    static let black = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static let red = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static let orange = UIColor(red: 255.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static let yellow = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static let green = UIColor(red: 0.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static let cyan = UIColor(red: 0.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let blue = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let purple = UIColor(red: 128.0/255.0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let pink = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    static var colors: [UIColor] {
        return [black, red, orange, yellow, green, cyan, blue, purple, pink, white]
    }

    static let background = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    static let contentBackground = UIColor.white//UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    static let divider = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)

//    let morhpu = UIColor(red: 61.0/255.0, green: 14.0/255.0, blue: 133.0/255.0, alpha: 1.0)
//    let morhpuColorBright = UIColor(red: 71.0/255.0, green: 17.0/255.0, blue: 153.0/255.0, alpha: 1.0)

    static let cover = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 0.7)
    static let infoText = UIColor.black
    static let descriptionText = UIColor.black

    static let tabSelection = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
}
