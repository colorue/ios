//
//  TabBarController.swift
//  Morphu
//
//  Created by Dylan Wight on 4/26/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barStyle = .Black
        self.tabBar.tintColor = morhpuColor
    }
}