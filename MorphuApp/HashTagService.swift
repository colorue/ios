//
//  HashTagService.swift
//  Colorue
//
//  Created by Dylan Wight on 9/26/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
import Firebase
import RealmSwift
import Realm

struct HashTagService {
    
    fileprivate let myRootRef = FIRDatabase.database().reference()
    let realm = try! Realm()
    
    let basePath = "hashTag"
    
    func add(hashtag: HashTag, to drawing: Drawing) {
        myRootRef.child("\(basePath)/\(hashtag.text)/\(drawing.id)").setValue(true)
    }
    
    func get(tag: String, callback: @escaping (HashTag?) -> ()) {
        myRootRef.child("\(basePath)/\(tag)").observeSingleEvent(of: .value, with: { snapshot in
            
            if let json = snapshot.value as? [String: Any] {
                if let hashtag = HashTag(JSON: json) {
                    try! self.realm.write() {
                        self.realm.add(hashtag, update: true)
//                        self.realm.create(HashTag.self)
                    }
                    callback(hashtag)
                }
            }
        })
    }
}
