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
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    if let drawingId = Database.string(for: .openDrawing) {
      openDrawing(drawingId)
      return true
    } else if !Database.bool(for: .saved) {
      // Start in drawing interface for new users
      openDrawing()
    }

    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    let notificationCenter = NotificationCenter.default
    // Saves active drawing
    notificationCenter.post(name: UIApplication.willResignActiveNotification, object: nil)
  }

  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    if (shortcutItem.type == "NewDrawing") {
      openDrawing()
    }
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {

    guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
          let drawingId = components.path?.replacingOccurrences(of: "/", with: "") else {
      return true
    }

    openDrawing(drawingId)
    return true
  }

  private func openDrawing(_ drawingId: String? = nil) {
    guard
      let galleryViewController = R.storyboard.gallery.instantiateInitialViewController(),
      let drawingViewController = R.storyboard.drawing.instantiateInitialViewController()
      else { return }
    drawingViewController.drawingId = drawingId
    self.window?.rootViewController = galleryViewController
    galleryViewController.pushViewController(drawingViewController, animated: false)
  }
}

