//
//  ColorueWidget.swift
//  ColorueWidget
//
//  Created by Dylan Wight on 5/12/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import WidgetKit
import SwiftUI
import RealmSwift

struct Provider: TimelineProvider {

  func placeholder(in context: Context) -> SimpleEntry {
    return SimpleEntry(date: Date())
  }

  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(date: Date())
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    var entries: [SimpleEntry] = []

    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    let currentDate = Date()
    for hourOffset in 0 ..< 5 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
      let entry = SimpleEntry(date: entryDate)
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
}

struct ColorueWidgetEntryView : View {
  var entry: Provider.Entry
  private static let deeplinkURL: URL = URL(string: "colorue://")!

  var body: some View {
    if let base64 = StoreShared.string(forKey: "openDrawing64") {
      Image(uiImage: UIImage.fromBase64(base64)).resizable().scaledToFill().widgetURL(ColorueWidgetEntryView.deeplinkURL)
    } else {
      Image("Polygon Tool")
    }
  }
}

@main
struct ColorueWidget: Widget {
  let kind: String = "ColorueWidget"

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
