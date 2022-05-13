//
//  Haptic.swift
//  Colorue
//
//  Created by Dylan Wight on 5/6/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

struct Haptic {
  static var selection: UISelectionFeedbackGenerator?
  static var notification: UINotificationFeedbackGenerator?

  static func selectionChanged (prepare: Bool = false) {
    selection = UISelectionFeedbackGenerator()
    selection?.selectionChanged()
    if prepare {
      selection?.prepare()
    } else {
      selection = nil
    }
  }

  static func notificationOccurred (_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
    notification = UINotificationFeedbackGenerator()
    notification?.notificationOccurred(notificationType)
    notification = nil
  }
}
