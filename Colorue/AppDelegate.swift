//
//  AppDelegate.swift
//  Colorue
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

let dev = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let bundle = Bundle.main.infoDictionary!
        




        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        let notificationCenter = NotificationCenter.default
        // Saves active drawing
        notificationCenter.post(name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    
    var previousController: UIViewController?

    
    // MARK: TabBarControllerDelegate Methods
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }

}
