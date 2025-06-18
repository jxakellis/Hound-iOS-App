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
    
    /// The currently active NSLayoutConstraint managed by this wrapper.
    private(set) var constraint: NSLayoutConstraint
    
    /// The original constant value.
    let originalConstant: CGFloat
    
    /// The original multiplier value, if applicable.
    let originalMultiplier: CGFloat?
    
    /// Used for restoring constraint's isActive state when swapping.
    private var wasActive: Bool {
        get { constraint.isActive }
        set { constraint.isActive = newValue }
    }
    
    // MARK: - Init
    
    /// Wraps an existing NSLayoutConstraint, capturing its initial constant and multiplier (if any).
    init(wrapping constraint: NSLayoutConstraint) {
        self.constraint = constraint
        self.originalConstant = constraint.constant
        
        if let multiplier = GeneralLayoutConstraint.extractMultiplier(from: constraint) {
            self.originalMultiplier = multiplier
        }
        else {
            self.originalMultiplier = nil
        }
    }
    
    // MARK: - API
    
    /// The current constant.
    var constant: CGFloat {
        get { constraint.constant }
        set { constraint.constant = newValue }
    }
    
    /// Restore the original constant value.
    func restoreConstant() {
        constraint.constant = originalConstant
    }
    
    /// The current multiplier (if any).
    var multiplier: CGFloat? {
        GeneralLayoutConstraint.extractMultiplier(from: constraint)
    }
    
    /// Change the multiplier. If the multiplier is unchanged, does nothing.
    /// Replaces, reactivates, and updates the internal constraint reference.
    func setMultiplier(_ newMultiplier: CGFloat) {
        guard let origMultiplier = multiplier else {
            assertionFailure("Tried to set multiplier on a constraint without one (likely created with constant, not relative constraint)")
            return
        }
        guard abs(origMultiplier - newMultiplier) > 0.0001 else { return }
        guard let newConstraint = GeneralLayoutConstraint.rebuildConstraint(
            from: constraint, withMultiplier: newMultiplier
        ) else {
            assertionFailure("Failed to rebuild constraint with new multiplier")
            return
        }
        swapConstraint(to: newConstraint)
    }
    
    /// Restore the original multiplier, if it has changed.
    func restoreMultiplier() {
        guard let origMultiplier = originalMultiplier else { return }
        setMultiplier(origMultiplier)
    }
    
    /// Restore both constant and multiplier to original values.
    func restore() {
        restoreConstant()
        restoreMultiplier()
    }
    
    /// Returns the underlying NSLayoutConstraint (for adding/removing from layout).
    /// If you need to activate/deactivate the constraint, use these:
    func activate() {
        constraint.isActive = true
    }
    
    func deactivate() {
        constraint.isActive = false
    }
    
    // MARK: - Internal Replacement
    
    /// Swaps the currently managed NSLayoutConstraint for a new one, activating and deactivating as needed.
    private func swapConstraint(to newConstraint: NSLayoutConstraint) {
        let wasActive = constraint.isActive
        
        // Deactivate old
        constraint.isActive = false
        NSLayoutConstraint.deactivate([constraint])
        
        // Try to preserve priority, identifier, etc.
        newConstraint.priority = constraint.priority
        newConstraint.identifier = constraint.identifier
        
        // Activate new if needed
        newConstraint.isActive = wasActive
        if wasActive {
            NSLayoutConstraint.activate([newConstraint])
        }
        
        // Update reference
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
        // Multiplier is only relevant for constraints relating two anchors (not for .notAnAttribute)
        let secondItem = old.secondItem
        
        if old.firstAttribute == .notAnAttribute || secondItem == nil {
            // No multiplier to change
            return nil
        }
        
        // Create new constraint (copying all relevant fields)
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
