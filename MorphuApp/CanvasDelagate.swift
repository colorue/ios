//
//  CanvasDelagate.swift
//  Morphu
//
//  Created by Dylan Wight on 4/10/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

protocol CanvasDelagate {
    func getCurrentColor() -> UIColor
    func getCurrentBrushSize() -> Float
    func setUnderfingerView(underFingerImage: UIImage)
    func hideUnderFingerView()
    func showUnderFingerView()
    func setColor(color: UIColor)
    func getDropperActive() -> Bool
    func setDropperActive(active: Bool)
}