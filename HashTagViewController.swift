//
//  PromptViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 7/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import Realm

class HashTagViewController: DrawingListViewController {
    
    // MARK: - Properties
    var hashTag: HashTag? {
        didSet {
            guard let hashTag = hashTag else { return }
            drawingSource = { return [Drawing]() }
            navigationItem.title = "#\(hashTag.text ?? "")"
        }
    }
    
    var text: String? {
        didSet {
            guard let text = text else { return }
            HashTagService().get(tag: text, callback: { hashTag in
                self.hashTag = hashTag
                
                
                
                do {
                    let hashtags = try Realm().objects(HashTag.self).sorted(byProperty: "text", ascending: true)
                    print(hashtags.count)
                } catch { return }
                
            })
        }
    }
    
    // MARK: - View Setup
    
    override func viewDidLoad() {
        bottomRefreshControl.addTarget(self, action: #selector(HashTagViewController.refresh), for: .valueChanged)
        super.viewDidLoad()
    }
}
