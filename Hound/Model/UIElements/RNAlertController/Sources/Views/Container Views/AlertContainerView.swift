//
//  AlertContainerView.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 5/2/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import UIKit

class AlertContainerView: UIVisualEffectView {

    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = [.flexibleHeight]
        layer.opacity = 0.0
        layer.cornerRadius = 10
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience init() {
        self.init(effect: nil)
        effect = UIBlurEffect(style: isDarkInterfaceStyle ? .dark : .light)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        effect = UIBlurEffect(style: isDarkInterfaceStyle ? .dark : .light)
    }

}
