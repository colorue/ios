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
    notificationCenter.post(name: UIApplication.willResignActiveNotification, object: nil)
  }

  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    if (shortcutItem.type == "NewDrawing") {
      openDrawing()
    }
  }

  // App launched
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      guard let _: UIWindowScene = scene as? UIWindowScene else { return }
      maybeOpenedFromWidget(urlContexts: connectionOptions.urlContexts)
  }

  // App opened from background
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
      maybeOpenedFromWidget(urlContexts: URLContexts)
  }

  private func maybeOpenedFromWidget(urlContexts: Set<UIOpenURLContext>) {
      guard let _: UIOpenURLContext = urlContexts.first(where: { $0.url.scheme == "colorue" }) else { return }
      print("🚀 Launched from widget")
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
