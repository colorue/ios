//
//  AppDelegate.swift
//  Canvix
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        
//        if let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView  {
//            statusBar.backgroundColor = whiteColor
//        }
        
//        let settings: UIUserNotificationSettings =
//            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
//        application.registerUserNotificationSettings(settings)
//        application.registerForRemoteNotifications()
        
//        connectToFcm()
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
//        connectToFcm()
    }
    
    func application(application: UIApplication, openURL url: NSURL,
                     sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        // Saves active drawing
        notificationCenter.postNotificationName(UIApplicationWillResignActiveNotification, object: nil)
    }
    
    // MARK: TabBarControllerDelegate Methods
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        let api = API.sharedInstance
        
        let destinationNavigationController = viewController as? UINavigationController
        let targetController = destinationNavigationController?.topViewController
        
        
        if let profileView = targetController as? ProfileViewController {
            let nav = profileView.navigationController as! NavigationController
            nav.setColors(redColor)
            tabBarController.tabBar.tintColor = redColor
            if profileView.userInstance == nil {
                profileView.navigationItem.title = api.getActiveUser().username
                profileView.userInstance = api.getActiveUser()
                profileView.addLogoutButton()
            }
        } else if let friendsList = targetController as? InviteViewController {
            let nav = friendsList.navigationController as! NavigationController
            nav.setColors(blueColor)
            tabBarController.tabBar.tintColor = blueColor
        } else if targetController is DrawingViewController {
            if let newVC = tabBarController.storyboard?.instantiateViewControllerWithIdentifier("DrawingViewController") {
                tabBarController.presentViewController(newVC, animated: true, completion: nil)
                return false
            }
        } else if let search = targetController as? SearchViewController {
                let nav = search.navigationController as! NavigationController
                nav.setColors(orangeColor)
                tabBarController.tabBar.tintColor = orangeColor
        } else if let wall = targetController as? WallViewController {
            let nav = wall.navigationController as! NavigationController
            nav.setColors(purpleColor)
            tabBarController.tabBar.tintColor = purpleColor
        }
        
        return true
    }

//    func applicationDidEnterBackground(application: UIApplication) {
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        
//        FIRMessaging.messaging().disconnect()
//    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
//                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//        // TODO: Handle data of notification
//        
//        // Print message ID.
//        print("Message ID: \(userInfo["gcm.message_id"]!)")
//        
//        // Print full message.
//        print("%@", userInfo)
//    }
    
    
//    func tokenRefreshNotificaiton(notification: NSNotification) {
//        let refreshedToken = FIRInstanceID.instanceID().token()!
//        print("InstanceID token: \(refreshedToken)")
//        
//        // Connect to FCM since connection may have failed when attempted before having a token.
//        connectToFcm()
//    }
    
//    func connectToFcm() {
//        FIRMessaging.messaging().connectWithCompletion { (error) in
//            if (error != nil) {
//                print("Unable to connect with FCM. \(error)")
//            } else {
//                print("Connected to FCM.")
//            }
//        }
//    }
    


}