//
//  HoundDynamicCorners.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HoundDynamicCorners: AnyObject {
    var shouldRoundCorners: Bool { get }
    var staticCornerRadius: CGFloat? { get }
}

extension HoundDynamicCorners where Self: UIView {
    func updateCornerRounding() {
        if shouldRoundCorners {
            self.layer.masksToBounds = true
            self.layer.cornerRadius = shouldRoundCorners ? (staticCornerRadius ?? (self.bounds.height / 2.0)) : 0.0
            self.layer.cornerCurve = .continuous
        }
    }
}
