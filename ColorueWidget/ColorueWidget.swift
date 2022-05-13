//
//  ColorueWidget.swift
//  ColorueWidget
//
//  Created by Dylan Wight on 5/12/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

  func placeholder(in context: Context) -> SimpleEntry {
    return SimpleEntry(date: Date())
  }

  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(date: Date())
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let timeline = Timeline(entries: [SimpleEntry(date: Date())], policy: .atEnd)
    completion(timeline)
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
}

struct ColorueWidgetEntryView : View {
  var entry: Provider.Entry

  var body: some View {
    if let base64 = StoreShared.string(forKey: "widgetDrawingImage"),
       let drawingId = StoreShared.string(forKey: "widgetDrawingId"),
       let deeplinkURL: URL = URL(string: "colorue://widget/\(drawingId)") {
      Image(uiImage: UIImage.fromBase64(base64)).resizable().scaledToFill().widgetURL(deeplinkURL)
    }
  }
}

@main
struct ColorueWidget: Widget {
  let kind: String = "com.colorue.app.ColorueWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      ColorueWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Canvas")
    .description("The widget shows your most recent drawing.")
  }
}

struct ColorueWidget_Previews: PreviewProvider {
  static var previews: some View {
    ColorueWidgetEntryView(entry: SimpleEntry(date: Date()))
      .previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}
