//
//  DrawingDelagate.swift
//  Morphu
//
//  Created by Dylan Wight on 5/25/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit

protocol DrawingDelagate {
    func imageLoaded(image: UIImage)
    func setProgress(progress: Float)
}