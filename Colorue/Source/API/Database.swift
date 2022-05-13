//
//  Database.swift
//  Colorue
//
//  Created by Dylan Wight on 5/12/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import RealmSwift
import WidgetKit

struct Database {
  static var realm: Realm {
    return try! Realm()
  }

  static let shared = UserDefaults(suiteName: "group.com.colorue.app")
  static let defaults = UserDefaults()

  static func update (drawing: Drawing?) {
    guard let base64 = drawing?.base64, let drawingId = drawing?.id else { return }
    shared?.setValue(base64, forKey: "widgetDrawingImage")
    shared?.setValue(drawingId, forKey: "widgetDrawingId")
    WidgetCenter.shared.reloadTimelines(ofKind: "com.colorue.app.ColorueWidget")
  }
}
