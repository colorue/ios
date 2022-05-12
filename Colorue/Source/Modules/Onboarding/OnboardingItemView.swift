//
//  OnboardingItemView.swift
//  Colorue
//
//  Created by Dylan Wight on 5/12/22.
//  Copyright © 2022 Dylan Wight. All rights reserved.
//

import Foundation

class OnboardingItemView: UIStackView {
  convenience init (icon: UIImage?, title: String?, subtitle: String?) {
    self.init()
    axis = .horizontal
    distribution = .fill
    alignment = .center
    spacing = 16.0

    let iconView = UIImageView()
    iconView.tintColor = Theme.purple
    iconView.image = icon
    iconView.height(constant: 50.0)
    iconView.width(constant: 50.0)
    addArrangedSubview(iconView)

    let textStack = UIStackView()
    textStack.axis = .vertical
    textStack.distribution = .fill
    textStack.alignment = .fill
    textStack.spacing = 4.0
    addArrangedSubview(textStack)

    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
    textStack.addArrangedSubview(titleLabel)

    let subtitleLabel = UILabel()
    subtitleLabel.text = subtitle
    subtitleLabel.font = UIFont.systemFont(ofSize: 17.0)
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.numberOfLines = 0
    textStack.addArrangedSubview(subtitleLabel)
  }
}
