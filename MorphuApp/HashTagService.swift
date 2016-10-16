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
    
    let basePath = "hashTags"
    
    func add(hashtag: HashTag, to drawing: Drawing) {
        let ref = myRootRef.child("\(basePath)/\(hashtag.text)")
        ref.child("text").setValue(hashtag.text)
        ref.child("timeStamp").setValue(hashtag.timeStamp)
        ref.child("drawings/\(drawing.id)").setValue(true)
    }
    
    func get(tag: String, callback: @escaping (HashTag) -> ()) {
        let ref = myRootRef.child("\(basePath)/\(tag)")

        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            guard let value = snapshot.value as? [String : AnyObject] , snapshot.exists(), let text = value["text"] as? String else { return }
            
            let hashTag = HashTag(text: text)
            
            ref.child("drawings").observe(.childAdded, with: {snapshot in
                DrawingService().get(id: snapshot.key, callback: { (drawing, _) in
                    hashTag.add(drawing: drawing)
                })
            })
            
            callback(hashTag)
        })
    }
}
