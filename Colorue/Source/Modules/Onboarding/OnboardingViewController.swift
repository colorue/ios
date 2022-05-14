//
//  OnboardingViewController.swift
//  Colorue
//
//  Created by Dylan Wight on 5/12/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation
import UIKit

class OnboardingViewController: UIViewController {

  var type: KeyboardToolState = .none

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
      continueButton?.tintColor = .white
      continueButton?.titleLabel?.textColor = .white
      continueButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
      continueButton?.backgroundColor = R.color.purple()
      continueButton?.layer.cornerRadius = 12.0
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    titleLabel?.text = header
    continueButton?.backgroundColor = tint
    for itemView in itemViews {
      onboardingItemsStack?.addArrangedSubview(itemView)
    }
  }

  private var header: String? {
    get {
      switch type {
      case .none:
        return "Get Started"
      case .bullsEye:
        return "Aim Mode"
      case .straightLine:
        return "Lines & Polygons"
      case .curvedLine:
        return "Curve Tool"
      case .oval:
        return "Circles & Ovals"
      default:
        return nil
      }
    }
  }

  private var tint: UIColor? {
    get {
      switch type {
      case .none:
        return R.color.purple()
      case .straightLine:
        return R.color.red()
      case .curvedLine:
        return R.color.orange()
      case .oval:
        return R.color.darkGreen()
      case .bullsEye:
        return R.color.blue()
      default:
        return nil
      }
    }
  }

  private var itemViews: [OnboardingItemView] {
    get {
      switch type {
      case .none:
        return [
          OnboardingItemView(
            icon: UIImage(systemName: "viewfinder"),
            title: "Underfinder View",
            subtitle: "See beneath your thumb to draw more accurately.",
            tint: tint),
          OnboardingItemView(
            icon: UIImage(systemName: "hand.tap"),
            title: "Color Mixing",
            subtitle: "Tap a color tab to mix it with the current color, press to switch.",
            tint: tint),
          OnboardingItemView(
            icon: UIImage(systemName: "paintbrush"),
            title: "Brush Size",
            subtitle: "Adjust the center slider to change your stroke width.",
            tint: tint)
        ]
      case .bullsEye:
        return [
          OnboardingItemView(
            icon: UIImage(systemName: "viewfinder"),
            title: "Find starting point",
            subtitle: "Move your finger across the canvas to find the right starting point.",
            tint: tint),
          OnboardingItemView(
            icon: UIImage(systemName: "circle.fill"),
            title: "Then draw",
            subtitle: "Hold down an action buttons with your other hand to draw.",
            tint: tint)
        ]
      case .straightLine:
        return [
          OnboardingItemView(
            icon: UIImage(systemName: "hand.tap"),
            title: "Start your line",
            subtitle: "Aim, then tap an action button to begin a your line.",
            tint: tint),
          OnboardingItemView(
            icon: UIImage(systemName: "line.diagonal"),
            title: "Add Segments",
            subtitle: "Without releasing your drawing finger, move it and tap again.",
            tint: tint),
          OnboardingItemView(
            icon: R.image.polygonTool(),
            title: "Complete Shapes",
            subtitle: "You can keep adding on line segments to draw polygons.",
            tint: tint),
        ]
      case .curvedLine:
        return [
          OnboardingItemView(
            icon: UIImage(systemName: "hand.tap"),
            title: "Start your curve",
            subtitle: "Aim, then tap an action button to begin a your curve.",
            tint: tint),
          OnboardingItemView(
            icon: UIImage(systemName: "line.diagonal"),
            title: "Add point",
            subtitle: "Without releasing your drawing finger, move it and tap again.",
            tint: tint),
          OnboardingItemView(
            icon: R.image.bezierTool(),
            title: "Curve through points",
            subtitle: "The curve will pass through all the points you add.",
            tint: tint),
        ]
      case .oval:
        return [
          OnboardingItemView(
            icon: UIImage(systemName: "hand.tap"),
            title: "Position the center",
            subtitle: "Aim, then tap an action button to begin a your circle.",
            tint: tint),
          OnboardingItemView(
            icon: UIImage(systemName: "circle"),
            title: "Drag out circle",
            subtitle: "Without releasing your drawing finger, move it to create a circle.",
            tint: tint),
          OnboardingItemView(
            icon: R.image.ovalTool(),
            title: "Stretch to oval",
            subtitle: "Tap again, then stretch or squish the circle into an oval.",
            tint: tint),
        ]
      default:
        return []
      }
    }
  }
}
