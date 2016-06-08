//
//  NavigationController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/12/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UINavigationBarDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = UIFont(name: "Playtime With Hot Toddies", size: 22)!

        navigationBar.barTintColor = UIColor.whiteColor()
        navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName: redColor]
        navigationBar.translucent = false
        
        self.navigationBar.tintColor = blueColor
        setStatusBarBackgroundColor(UIColor.whiteColor())
    }

    func setStatusBarBackgroundColor(color: UIColor) {
        guard  let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView else {
            return
        }
        statusBar.backgroundColor = color
    }
}