//
//  GeneralLayoutConstraint.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/17/25.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// Wrapper for NSLayoutConstraint that preserves original constant and multiplier,
/// and handles safe replacement (activation, deactivation) if the multiplier is changed.
/// All references and changes should be made through this class.
final class GeneralLayoutConstraint {
    
    // MARK: - Properties
    
    /// The minimum allowed multiplier (to avoid UIKit bugs from multiplier == 0.0)
    static let minimumMultiplier: CGFloat = 0.00000001

    /// The currently active NSLayoutConstraint managed by this wrapper.
    private(set) var constraint: NSLayoutConstraint
    
    /// The original constant value.
    let originalConstant: CGFloat
    
    /// The original multiplier value, if applicable.
    let originalMultiplier: CGFloat?
    
    /// Tracks if the constraint is in a "collapsed" state.
    var isCollapsed: Bool {
        return abs(multiplier ?? 1.0) < Self.minimumMultiplier
    }
    
    // MARK: - Init
    
    /// Wraps an existing NSLayoutConstraint, capturing its initial constant and multiplier (if any).
    init(wrapping constraint: NSLayoutConstraint) {
        self.constraint = constraint
        self.originalConstant = constraint.constant
        self.originalMultiplier = GeneralLayoutConstraint.extractMultiplier(from: constraint)
    }
    
    // MARK: - API
    
    /// The current constant.
    var constant: CGFloat {
        get { constraint.constant }
        set { constraint.constant = newValue }
    }
    
    /// The current multiplier (if any).
    var multiplier: CGFloat? {
        GeneralLayoutConstraint.extractMultiplier(from: constraint)
    }
    
    var isActive: Bool {
        get { constraint.isActive }
        set { constraint.isActive = newValue }
    }
    
    /// Change the multiplier. If a zero multiplier is passed, will coalesce to minimumMultiplier instead.
    func setMultiplier(_ newMultiplier: CGFloat) {
        // Coalesce zero to minimumMultiplier for UIKit safety
        let safeMultiplier: CGFloat = (abs(newMultiplier) < Self.minimumMultiplier) ? Self.minimumMultiplier : newMultiplier

        guard let origMultiplier = multiplier else {
            assertionFailure("Tried to set multiplier on a constraint without one (likely created with constant, not relative constraint)")
            return
        }
        guard abs(origMultiplier - safeMultiplier) > Self.minimumMultiplier else { return }
        guard let newConstraint = GeneralLayoutConstraint.rebuildConstraint(
            from: constraint, withMultiplier: safeMultiplier
        ) else {
            assertionFailure("Failed to rebuild constraint with new multiplier")
            return
        }
        swapConstraint(to: newConstraint)
    }
    
    /// Restore both constant and multiplier to original values.
    func restore() {
        constraint.constant = originalConstant
        if let origMultiplier = originalMultiplier {
            setMultiplier(origMultiplier)
        }
    }
    
    // MARK: - Internal Replacement
    
    /// Swaps the currently managed NSLayoutConstraint for a new one, activating and deactivating as needed.
    private func swapConstraint(to newConstraint: NSLayoutConstraint) {
        let wasActive = constraint.isActive
        constraint.isActive = false
        NSLayoutConstraint.deactivate([constraint])
        newConstraint.priority = constraint.priority
        newConstraint.identifier = constraint.identifier
        newConstraint.isActive = wasActive
        if wasActive {
            NSLayoutConstraint.activate([newConstraint])
        }
        self.constraint = newConstraint
    }
    
    // MARK: - Helpers
    
    /// Attempts to extract the multiplier from the constraint (KVC, as UIKit doesn't expose this).
    private static func extractMultiplier(from constraint: NSLayoutConstraint) -> CGFloat? {
        if constraint.firstAttribute != .notAnAttribute && constraint.secondItem != nil {
            return (constraint.value(forKey: "multiplier") as? CGFloat)
        }
        return nil
    }
    
    /// Build a new constraint by copying all parameters except multiplier, and using the specified multiplier.
    private static func rebuildConstraint(from old: NSLayoutConstraint, withMultiplier multiplier: CGFloat) -> NSLayoutConstraint? {
        guard let firstItem = old.firstItem else { return nil }
        let secondItem = old.secondItem
        
        if old.firstAttribute == .notAnAttribute || secondItem == nil {
            return nil
        }
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: old.firstAttribute,
            relatedBy: old.relation,
            toItem: secondItem,
            attribute: old.secondAttribute,
            multiplier: multiplier,
            constant: old.constant
        )
        newConstraint.priority = old.priority
        newConstraint.identifier = old.identifier
        return newConstraint
    }
}
