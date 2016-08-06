


import UIKit

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
        print(prompt!.text)
    }
}