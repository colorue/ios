//
//  Database.swift
//  Colorue
//
//  Created by Dylan Wight on 5/12/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import RealmSwift
import WidgetKit

enum DataKey: String {
  typealias RawValue = String
  case colorRed = "colorRed"
  case colorGreen = "colorGreen"
  case colorBlue = "colorBlue"
  case colorAlpha = "colorAlpha"
  case brushSize = "brushSize"
  case savedDrawing = "savedDrawing"
  case saved = "saved"
  case tool = "tool"
  case openDrawing = "openDrawing"
  case drawingHowTo = "drawingHowTo"
  case howToStraightLine = "howToStraightLine"
  case howToCurvedLine = "howToCurvedLine"
  case howToOval = "howToOval"
  case howToBullsEye = "howToBullsEye"
  case widgetDrawingImage = "widgetDrawingImage"
  case widgetDrawingId = "widgetDrawingId"
  case lastReviewRequestAppVersion = "lastReviewRequestAppVersion"
  case reviewWorthyActionCount = "reviewWorthyActionCount"
  case firstRequest = "firstRequest"
}

struct Database {
  static var realm: Realm {
    return try! Realm()
  }

  private static let shared = UserDefaults(suiteName: "group.com.colorue.app")

  static func update (drawing: Drawing?) {
    guard let base64 = drawing?.base64, let drawingId = drawing?.id else { return }
    Database.set(base64, for: .widgetDrawingImage)
    Database.set(drawingId, for: .widgetDrawingId)
    WidgetCenter.shared.reloadTimelines(ofKind: "com.colorue.app.ColorueWidget")
  }

  static func set(_ value: Any?, for key: DataKey) {
    shared?.setValue(value, forKey: key.rawValue)
  }

  static func remove(key: DataKey) {
    shared?.removeObject(forKey: key.rawValue)
  }

  static func bool(for key: DataKey) -> Bool {
    return shared?.bool(forKey: key.rawValue) ?? false
  }

  static func string(for key: DataKey) -> String? {
    return shared?.string(forKey: key.rawValue)
  }

  static func integer(for key: DataKey) -> Int {
    return shared?.integer(forKey: key.rawValue) ?? 0
  }

  static func float(for key: DataKey) -> Float {
    return shared?.float(forKey: key.rawValue) ?? 0.0
  }
}
