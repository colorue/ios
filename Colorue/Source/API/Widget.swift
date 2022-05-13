//
//  Widget.swift
//  Colorue
//
//  Created by Dylan Wight on 5/13/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation
import WidgetKit

struct Widget {
  static func update (drawing: Drawing?) {
    guard let base64 = drawing?.base64, let drawingId = drawing?.id else { return }
    StoreShared.setValue(base64, forKey: "widgetDrawingImage")
    StoreShared.setValue(drawingId, forKey: "widgetDrawingId")
    WidgetCenter.shared.reloadTimelines(ofKind: "com.colorue.app.ColorueWidget")
  }
}
