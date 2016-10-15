//
//  PromptViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 7/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Firebase

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
                

                
            })
        }
    }
    
    // MARK: - View Setup
    
    override func viewDidLoad() {
        bottomRefreshControl.addTarget(self, action: #selector(HashTagViewController.refresh), for: .valueChanged)
        super.viewDidLoad()
    }
}
