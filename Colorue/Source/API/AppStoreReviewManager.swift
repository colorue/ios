//
//  AppStoreReviewManager.swift
//  Colorue
//
//  Created by Dylan Wight on 5/5/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//
//  https://www.raywenderlich.com/9009-requesting-app-ratings-and-reviews-tutorial-for-ios

import StoreKit

enum AppStoreReviewManager {
  static let minimumReviewWorthyActionCount = 5

  static func requestReviewIfAppropriate() {

    let defaults = UserDefaults.standard
    let bundle = Bundle.main

    var actionCount = defaults.integer(forKey: .reviewWorthyActionCount)
    actionCount += 1

    defaults.set(actionCount, forKey: .reviewWorthyActionCount)

    guard actionCount >= minimumReviewWorthyActionCount || !defaults.bool(forKey: .firstRequest) else {
      return
    }

    let bundleVersionKey = kCFBundleVersionKey as String
    let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
    let lastVersion = defaults.string(forKey: .lastReviewRequestAppVersion)

    guard lastVersion == nil || lastVersion != currentVersion else {
      return
    }

    SKStoreReviewController.requestReview()

    defaults.set(true, forKey: .firstRequest)
    defaults.set(0, forKey: .reviewWorthyActionCount)
    defaults.set(currentVersion, forKey: .lastReviewRequestAppVersion)
  }
}

extension String {
  static let lastReviewRequestAppVersion = "lastReviewRequestAppVersion"
  static let reviewWorthyActionCount = "reviewWorthyActionCount"
  static let firstRequest = "firstRequest"
}
