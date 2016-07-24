//
//  Pixel.swift
//  PaintBucket
//
//  Created by Jack Flintermann on 3/15/16.
//  Copyright © 2016 jflinter. All rights reserved.
//

import CoreGraphics

struct Pixel {
    let r, g, b, a: UInt8
    
    init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    init(memory: UInt32) {
        self.a = UInt8((memory >> 24) & 255)
        self.r = UInt8((memory >> 16) & 255)
        self.g = UInt8((memory >> 8) & 255)
        self.b = UInt8((memory >> 0) & 255)
    }
    
    init(color: UIColor) {
        let model = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor))
        if model == .Monochrome {
            var white: CGFloat = 0
            var alpha: CGFloat = 0
            color.getWhite(&white, alpha: &alpha)
            self.r = UInt8(white * 255)
            self.g = UInt8(white * 255)
            self.b = UInt8(white * 255)
            self.a = UInt8(alpha * 255)
        } else if model == .RGB {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            self.r = UInt8(r * 255)
            self.g = UInt8(g * 255)
            self.b = UInt8(b * 255)
            self.a = UInt8(a * 255)
        } else {
            self.r = 0
            self.g = 0
            self.b = 0
            self.a = 0
        }
    }
    
    var color: UIColor {
        return UIColor(red: CGFloat(self.r) / 255, green: CGFloat(self.g) / 255, blue: CGFloat(self.b) / 255, alpha: CGFloat(self.a) / 255)
    }
    
    var uInt32Value: UInt32 {
        var total = (UInt32(self.a) << 24)
        total += (UInt32(self.r) << 16)
        total += (UInt32(self.g) << 8)
        total += (UInt32(self.b) << 0)
        return total
    }
    
    static func componentDiff(l: UInt8, _ r: UInt8) -> UInt8 {
        return max(l, r) - min(l, r)
    }
    
    func diff(other: Pixel) -> Int {
        return Int(Pixel.componentDiff(self.r, other.r)) +
            Int(Pixel.componentDiff(self.g, other.g)) +
            Int(Pixel.componentDiff(self.b, other.b)) +
            Int(Pixel.componentDiff(self.a, other.a))
    }
    
    
}
