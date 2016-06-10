//
//  TabBarController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/26/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var initialIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = UIApplication.sharedApplication().delegate as? UITabBarControllerDelegate

        self.tabBar.barStyle = .Default
        self.tabBar.tintColor = redColor
        self.tabBar.translucent = false
        
        self.selectedIndex = initialIndex
    }
}