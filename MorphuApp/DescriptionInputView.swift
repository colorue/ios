//
//  DescriptionInputView.swift
//  Morphu
//
//  Created by Dylan Wight on 4/15/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

class DescriptionInputView: UIView, UITextViewDelegate, UIGestureRecognizerDelegate {
    var descriptionInput = UITextView()
    var placeholderLabel = UILabel()
    var promptCover = UIView()
    var cover = false
    var delagate: DescriptionInputDelagate
    var prompt: String
    
    let font = UIFont(name: "SF Cartoonist Hand", size: 25)

    
    init (frame: CGRect, cover: Bool, delagate: DescriptionInputDelagate, prompt: String? = "What's this a drawing of?") {
        self.cover = cover
        self.delagate = delagate
        self.prompt = prompt!
        super.init(frame: frame)
        display()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func display() {
        self.backgroundColor = UIColor.whiteColor()
        
        descriptionInput = UITextView(frame: self.frame)
        descriptionInput.backgroundColor = contentBackgroundColor
        descriptionInput.textAlignment = NSTextAlignment.Center
        descriptionInput.delegate = self
        descriptionInput.font = font
        descriptionInput.textColor = descriptionTextColor
        descriptionInput.textContainer.maximumNumberOfLines = 2
        descriptionInput.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        descriptionInput.text = "-"
        descriptionInput.text = ""      // hack to initially center text vertically
        descriptionInput.keyboardAppearance = .Dark
        self.addSubview(descriptionInput)
        
        placeholderLabel.frame = self.frame
        placeholderLabel.text =  self.prompt
        placeholderLabel.textColor = UIColor.lightGrayColor()
        placeholderLabel.textAlignment = NSTextAlignment.Center
        placeholderLabel.font = font
        placeholderLabel.lineBreakMode = .ByWordWrapping
        placeholderLabel.numberOfLines = 0
        placeholderLabel.backgroundColor = contentBackgroundColor // to hide the cursor
        self.addSubview(placeholderLabel)
        
        if self.cover {
            promptCover = UIView(frame: self.frame)
            promptCover.backgroundColor = coverColor
            let promptTap = UITapGestureRecognizer(target: self, action: #selector(DescriptionInputView.editPrompt(_:)))
            promptTap.delegate = self
            promptCover.addGestureRecognizer(promptTap)
            promptCover.hidden = true
            self.addSubview(promptCover)
            
            let separatorB = UIView(frame: CGRect(x: 0, y: self.frame.height-0.5, width: self.frame.width, height: 0.5))
            separatorB.backgroundColor = dividerColor
            self.addSubview(separatorB)
        }
    }
    
    func editPrompt(sender: UIGestureRecognizer) {
        self.promptCover.hidden = true
        self.descriptionInput.becomeFirstResponder()
        self.delagate.editDescription()
    }
    
    func getDescriptionText() -> String {
        return self.descriptionInput.text!
    }
    
    func hideKeyboard() {
        self.promptCover.hidden = false
        self.descriptionInput.resignFirstResponder()
    }
    
    func hasKeyboard() -> Bool {
        return self.descriptionInput.isFirstResponder()
    }

    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = !descriptionInput.text.isEmpty
    }
    
    // Force the text in a UITextView to always center itself.
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let textView = object as! UITextView
        var topCorrect = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        textView.contentInset.top = topCorrect
    }
    
    deinit {
        descriptionInput.removeObserver(self, forKeyPath: "contentSize")
    }
}
