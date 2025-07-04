//
//  NSLayoutConstraintExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/17/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    @discardableResult
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        // Deactivate the original constraint before creating the new one
        self.isActive = false

        // Create new constraint copying all the parameters but changing the multiplier
        let newConstraint = NSLayoutConstraint(
            item: self.firstItem as Any,
            attribute: self.firstAttribute,
            relatedBy: self.relation,
            toItem: self.secondItem,
            attribute: self.secondAttribute,
            multiplier: multiplier,
            constant: self.constant
        )
        // Copy priority and identifier
        newConstraint.priority = self.priority
        newConstraint.identifier = self.identifier

        // Activate the new constraint
        newConstraint.isActive = true

        return newConstraint
    }
    
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
