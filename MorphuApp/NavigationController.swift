//
//  NavigationController.swift
//  Colorue
//
//  Created by Dylan Wight on 4/12/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UINavigationBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let font = R.font.playtimeWithHotToddies(size: 22) {
          navigationBar.titleTextAttributes = [NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor: Theme.black]
        }
        navigationBar.barTintColor = UIColor.white
        navigationBar.isTranslucent = false
    }
    
    func setColors(_ mainColor: UIColor) {
        navigationBar.tintColor = mainColor
    }
}
