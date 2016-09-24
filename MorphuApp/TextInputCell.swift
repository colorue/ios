//
//  WriteCommentCell.swift
//  Colorue
//
//  Created by Dylan Wight on 5/24/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

protocol TextInputCellDelagate {
    var tintColor: UIColor { get }

    func submit(_ text: String) -> ()
}

class TextInputCell: UITableViewCell, UITextFieldDelegate {
    var delagate: TextInputCellDelagate?
    
    @IBOutlet weak var submitButton: UIButton? {
        didSet {
            submitButton?.setTitleColor(delagate?.tintColor, for: UIControlState())
        }
    }
    
    @IBOutlet weak var textField: UITextField?
    
    @IBAction func submit(_ sender: UIButton?) {
        if let text = textField?.text {
            delagate?.submit(text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.submit(self.submitButton)
        return true
    }
}
