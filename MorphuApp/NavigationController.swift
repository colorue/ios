//
//  NavigationController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/12/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UINavigationBarDelegate {
    
    let font = UIFont(name: "Playtime With Hot Toddies", size: 22)!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName: blackColor]

        navigationBar.barTintColor = UIColor.whiteColor()
        navigationBar.translucent = false
        
//        setStatusBarBackgroundColor(UIColor.whiteColor())
    }

//    func setStatusBarBackgroundColor(color: UIColor) {
//        guard  let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView else {
//            return
//        }
//        statusBar.backgroundColor = color
//    }
    
    func setColors(mainColor: UIColor) {

        navigationBar.tintColor = mainColor
    }
}