//
//  BrushSizeSlider.swift
//  Colorue
//
//  Created by Dylan Wight on 5/6/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import UIKit

let sliderConstant: Float = 2.0

class BrushSizeSlider: UISlider {

  private var pastSize: Float = 0.0

  var size: Float {
    get {
      return pow(self.value, sliderConstant)
    }
  }

  override init (frame: CGRect) {
    super.init(frame : frame)
    layoutSlider()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    layoutSlider()
  }

  func updateTint(color: UIColor, alpha: CGFloat) {
    let darkness = color.getDarkness(alpha: alpha)
    if (darkness < 1.6) {
      minimumTrackTintColor = UIColor.lightGray
      maximumTrackTintColor = UIColor.white
    } else if darkness < 2.67 {
      minimumTrackTintColor = UIColor.black
      maximumTrackTintColor = UIColor.white
    } else {
      minimumTrackTintColor = UIColor.black
      maximumTrackTintColor = UIColor.lightGray
    }
  }

  private func layoutSlider () {
    minimumTrackTintColor = UIColor.lightGray
    maximumTrackTintColor = UIColor.white
    maximumValue = pow(100, 1/sliderConstant)
    minimumValue = pow(1, 1/sliderConstant)
    addTarget(self, action: #selector(BrushSizeSlider.sliderMoved(_:)), for: .valueChanged)
    addTarget(self, action: #selector(BrushSizeSlider.sliderChanged(_:)), for: .touchUpInside)
  }

  @objc private func sliderMoved(_ sender: UISlider) {
    let newSize = Float(lroundf(sender.value))
    if newSize != pastSize {
      pastSize = newSize
      Haptic.selectionChanged(prepare: true)
    }
  }

  @objc private func sliderChanged(_ sender: UISlider) {
    let newSize = Float(lroundf(sender.value))
    sender.setValue(newSize, animated: true)
    Haptic.selection = nil
    Store.setValue(size, forKey: Prefs.brushSize)
  }
}
