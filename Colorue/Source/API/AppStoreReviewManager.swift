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
    let bundle = Bundle.main

    var actionCount = Database.integer(for: .reviewWorthyActionCount)
    actionCount += 1

    Database.set(actionCount, for: .reviewWorthyActionCount)

    guard actionCount >= minimumReviewWorthyActionCount || !Database.bool(for: .firstRequest)
    else { return }

    let bundleVersionKey = kCFBundleVersionKey as String
    let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
    let lastVersion = Database.string(for: .lastReviewRequestAppVersion)

    guard lastVersion == nil || lastVersion != currentVersion else {
      return
    }

    guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene  else { return }

    SKStoreReviewController.requestReview(in: scene)
    Database.set(true, for: .firstRequest)
    Database.set(0, for: .reviewWorthyActionCount)
    Database.set(currentVersion, for: .lastReviewRequestAppVersion)
  }
}
