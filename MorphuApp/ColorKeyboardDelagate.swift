//
//  ColorKeyboardDelagate.swift
//  Morphu
//
//  Created by Dylan Wight on 4/10/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

protocol ColorKeyboardDelagate {
    func undo()
    func trash()
    func getDropperActive() -> Bool
    func setDropperActive(active: Bool)
    func switchAlphaHowTo()
}