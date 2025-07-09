//
//  HoundDynamicBorder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HoundDynamicBorder: AnyObject {
    var borderColor: UIColor? { get }
}

extension HoundDynamicBorder where Self: UIView {
    func updateDynamicBorderColor(using previousTraitCollection: UITraitCollection?) {
        guard #available(iOS 13.0, *),
              traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection),
              let color = borderColor else { return }
        layer.borderColor = color.cgColor
    }
}
