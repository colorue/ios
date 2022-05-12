//
//  CGPoint+distanceSquared.swift
//  Colorue
//
//  Created by Dylan Wight on 5/7/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

extension CGPoint {
  // Uses distance squared for speed. See https://www.hackingwithswift.com/example-code/core-graphics/how-to-calculate-the-distance-between-two-cgpoints
  func distanceSquared(to: CGPoint) -> CGFloat {
    return (self.x - to.x) * (self.x - to.x) + (self.y - to.y) * (self.y - to.y)
  }
}
