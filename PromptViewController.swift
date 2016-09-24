//
//  PromptViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 7/1/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
import Firebase

class PromptViewController: DrawingListViewController {
    
    // MARK: - Properties
    var prompt: Prompt? {
        didSet {
            guard let prompt = prompt else { return }
            drawingSource = { return prompt.drawings }
            navigationItem.title = prompt.text
        }
    }
    
    // MARK: - View Setup
    
    override func viewDidLoad() {
        bottomRefreshControl.addTarget(self, action: #selector(PromptViewController.refresh), for: .valueChanged)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Draw", style: .plain,
                                                                target: self, action: #selector(PromptViewController.drawPrompt(_:)))
        super.viewDidLoad()
    }
    
    @objc fileprivate func drawPrompt(_ sender: UIBarButtonItem) {
        guard let prompt = prompt else { return }
        
        let activity = R.storyboard.drawing.drawingViewController()!
        if let drawingViewController = activity.topViewController as? DrawingViewController {
            drawingViewController.prompt = prompt
            self.present(activity, animated: true, completion: nil)
            FIRAnalytics.logEvent(withName: "drawPrompt", parameters: ["text":prompt.text as NSObject])
        }
    }
}
