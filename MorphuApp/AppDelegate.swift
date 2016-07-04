//
//  AppDelegate.swift
//  Canvix
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import AirshipKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        
        let config = UAConfig.defaultConfig()
        config.analyticsEnabled = false
        config.developmentLogLevel = UALogLevel.Warn
        UAirship.takeOff(config)

        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
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
    
    
    var previousController: UIViewController?

    
    // MARK: TabBarControllerDelegate Methods
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        let api = API.sharedInstance
        
        let destinationNavigationController = viewController as? UINavigationController
        let targetController = destinationNavigationController?.topViewController
        
        if let profileView = targetController as? ProfileViewController {
            let nav = profileView.navigationController as! NavigationController
            nav.setColors(purpleColor)
            if profileView.userInstance == nil {
                profileView.tintColor = purpleColor
                profileView.navigationItem.title = api.getActiveUser().username
                profileView.userInstance = api.getActiveUser()
                profileView.addLogoutButton()
            }
            if previousController == viewController {
                profileView.scrollToTop()
            }
        } else if let friendsList = targetController as? FriendsViewController {
            friendsList.addInviteButton()
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
            if previousController == viewController {
                search.scrollToTop()
            }
        } else if let wall = targetController as? WallViewController {
            let nav = wall.navigationController as! NavigationController
            nav.setColors(redColor)
            if previousController == viewController {
                wall.scrollToTop()
            }
        }
        
        self.previousController = viewController

        return true
    }

}