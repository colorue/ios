//
//  AppDelegate.swift
//  Colorue
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import AirshipKit


let dev = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let bundle = Bundle.main.infoDictionary!
        

        if bundle["CFBundleIdentifier"] as! String == "Wight-Dylan.Colorue.dev" {
            let options = FIROptions(contentsOfFile: R.file.googleServiceInfoDevPlist.path())!
            FIRApp.configure(with: options)
        } else {
            FIRApp.configure()
        }
        
        FIRDatabase.database().persistenceEnabled = true
        
        let config = UAConfig.default()
        config.isAnalyticsEnabled = false
        config.developmentLogLevel = UALogLevel.warn
        UAirship.takeOff(config)
        
        
        let facebook = FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        print(facebook)
        
        return facebook
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(_ application: UIApplication, open url: URL,
                     sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        let notificationCenter = NotificationCenter.default
        // Saves active drawing
        notificationCenter.post(name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    
    var previousController: UIViewController?

    
    // MARK: TabBarControllerDelegate Methods
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
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
            let nav = friendsList.navigationController as! NavigationController
            nav.setColors(blueColor)
            tabBarController.tabBar.tintColor = blueColor
            
            
            
        } else if targetController is DrawingViewController {
            
            if let drawingController = R.storyboard.drawing.drawingViewController() {
                tabBarController.present(drawingController, animated: true, completion: nil)
                return false
            }
        
        } else if let search = targetController as? ExploreViewController {
            let nav = search.navigationController as! NavigationController
            nav.setColors(orangeColor)
            search.tintColor = orangeColor
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
