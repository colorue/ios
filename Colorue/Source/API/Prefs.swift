//
//  Prefs.swift
//  Colorue
//
//  Created by Dylan Wight on 8/7/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

struct Prefs {
  // MARK: Save Drawing State

  static let colorRed = "colorRed"
  static let colorGreen = "colorGreen"
  static let colorBlue = "colorBlue"
  static let colorAlpha = "colorAlpha"
  static let brushSize = "brushSize"
  static let savedDrawing = "savedDrawing"
  static let saved = "saved"
  static let tool = "tool"

  // MARK: Tutorials
}

let Store = UserDefaults.standard

let StoreShared = UserDefaults(suiteName: "group.com.colorue.app")!
