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
        bottomRefreshControl.addTarget(self, action: #selector(PromptViewController.refresh), forControlEvents: .ValueChanged)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Draw", style: .Plain,
                                                                target: self, action: #selector(PromptViewController.drawPrompt(_:)))
        super.viewDidLoad()
    }
    
    @objc private func drawPrompt(sender: UIBarButtonItem) {
        guard let prompt = prompt else { return }
        
        let activity = R.storyboard.drawing.drawingViewController()!
        if let drawingViewController = activity.topViewController as? DrawingViewController {
            drawingViewController.prompt = prompt
            self.presentViewController(activity, animated: true, completion: nil)
            FIRAnalytics.logEventWithName("drawPrompt", parameters: ["text":prompt.text])
        }
    }
}