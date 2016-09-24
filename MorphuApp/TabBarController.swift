//
//  TabBarController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/26/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var initialIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate

        self.tabBar.barStyle = .default
        self.tabBar.isTranslucent = false
        
        self.selectedIndex = initialIndex
    }
    
    @IBAction func backToMain(_ segue: UIStoryboardSegue) {}
}
