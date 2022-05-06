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

    if let drawingId = UserDefaults.standard.string(forKey: "openDrawing") {
      openDrawing(drawingId)
      return true
    } else if !UserDefaults.standard.bool(forKey: Prefs.saved) {
      // Start in drawing interface for new users
      openDrawing()
    }

    return true
  }
  
  
  func applicationWillResignActive(_ application: UIApplication) {
    let notificationCenter = NotificationCenter.default
    // Saves active drawing
    notificationCenter.post(name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
  }

  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    if (shortcutItem.type == "NewDrawing") {
      openDrawing()
    }
  }

  private func openDrawing(_ drawingId: String? = nil) {
    guard
      let drawingsViewController = R.storyboard.drawings.instantiateInitialViewController(),
      let drawingViewController = R.storyboard.drawing.instantiateInitialViewController()
      else { return }
    drawingViewController.drawingId = drawingId
    self.window?.rootViewController = drawingsViewController
    drawingsViewController.pushViewController(drawingViewController, animated: false)
  }
}
