//
//  Database.swift
//  Colorue
//
//  Created by Dylan Wight on 5/12/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import RealmSwift

struct Database {
  static var shared: Realm {
//    let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.colorue.app")
//
//
//
//    print("url", url)
//    let config = Realm.Configuration(fileURL: url)
//
//    let realm =  try! Realm(configuration: config)
//
//    let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path
//    try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none],
//                                            ofItemAtPath: folderPath)
    return try! Realm()
  }
}

