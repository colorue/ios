//
//  HashTagService.swift
//  Colorue
//
//  Created by Dylan Wight on 9/26/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
import Firebase

struct HashTagService {
    
    fileprivate let myRootRef = FIRDatabase.database().reference()
    
    let basePath = "hashTag"
    
    func add(hashtag: HashTag, to drawing: Drawing) {
        myRootRef.child("\(basePath)/\(hashtag.text)/\(drawing.id)").setValue(true)
    }
    
    func get(tag: String, callback: @escaping (HashTag?) -> ()) {
        myRootRef.child("\(basePath)/\(tag)").observeSingleEvent(of: .value, with: { snapshot in
            
            if let json = snapshot.value as? [String: Any] {
//                if let hashtag = HashTag(JSON: json) {
//                    callback(hashtag)
//                }
            }
        })
    }
}
