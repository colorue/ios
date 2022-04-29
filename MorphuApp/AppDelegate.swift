//
//  AppDelegate.swift
//  Colorue
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        let bundle = Bundle.main.infoDictionary!

//        FirebaseApp.configure()
//        Database.database().isPersistenceEnabled = true
//        Auth.auth().signInAnonymously { authResult, error in
//          guard let user = authResult?.user else {
//            print(error)
//            return
//          }
//          print("user", user.uid)
//        }

        return true
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        let notificationCenter = NotificationCenter.default
        // Saves active drawing
        notificationCenter.post(name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
}
