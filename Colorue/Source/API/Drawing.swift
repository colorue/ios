//
//  Drawing.swift
//  Colorue
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import RealmSwift
import Foundation
import UIKit

class Drawing: Object {
  @Persisted(primaryKey: true) var id: String = NSUUID().uuidString
  @Persisted var base64: String?
  @Persisted var createdAt: Double = Date().timeIntervalSince1970
  @Persisted var updatedAt: Double = Date().timeIntervalSince1970

  var image: UIImage? {
    get {
      guard let base64 = base64 else { return nil }
      return UIImage.fromBase64(base64)
    }
  }
}
