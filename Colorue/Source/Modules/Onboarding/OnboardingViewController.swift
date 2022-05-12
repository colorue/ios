//
//  OnboardingViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 5/12/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation
import UIKit

enum OnboardingTypes: Int, CaseIterable {
  case welcome = 0
  case bullsEye = 1
  case straightLine = 2
  case curvedLine = 3
  case oval = 4
}

class OnboardingViewController: UIViewController {

  var type: OnboardingTypes? {
    didSet {
      titleLabel?.text = header
    }
  }

  @IBOutlet var onboardingItemsStack: UIStackView? {
    didSet {
      onboardingItemsStack?.distribution = .fill
      onboardingItemsStack?.alignment = .fill
      onboardingItemsStack?.spacing = 24.0
    }
  }

  @IBOutlet var titleLabel: UILabel? {
    didSet {
      titleLabel?.font = .systemFont(ofSize: 40.0, weight: .bold)
    }
  }

  @IBOutlet var continueButton: UIButton? {
    didSet {
      continueButton?.tintColor = Theme.purple
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    for itemView in itemViews {
      onboardingItemsStack?.addArrangedSubview(itemView)
    }
  }

  private var header: String? {
    get {
      guard let type = type else { return nil }
      switch type {
      case .welcome:
        return "Get Started"
      case .bullsEye:
        return "Aim Mode"
      case .straightLine:
        return "Lines & Polygons"
      case .curvedLine:
        return "Curve Tool"
      case .oval:
        return "Circles & Ovals"
      }
    }
  }

  private var itemViews: [OnboardingItemView] {
    get {
      guard let type = type else { return [] }
      switch type {
      case .welcome:
        return [
          OnboardingItemView(
            icon: UIImage(systemName: "viewfinder"),
            title: "Underfinder View",
            subtitle: "See beneath your thumb to draw more accurately. "),
          OnboardingItemView(
            icon: UIImage(systemName: "hand.tap"),
            title: "Color Mixing",
            subtitle: "Tap a color tab to mix it with the current color, press to switch."),
          OnboardingItemView(
            icon: UIImage(systemName: "paintbrush"),
            title: "Brush Size",
            subtitle: "Adjust the center slider to change your stroke width.")
        ]
      case .bullsEye:
        return []
      case .straightLine:
        return []
      case .curvedLine:
        return []
      case .oval:
        return []
      }
    }
  }
}
