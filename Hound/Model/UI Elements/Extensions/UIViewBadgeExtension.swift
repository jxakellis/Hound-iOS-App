//
//  UIViewBadgeExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/4/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import ObjectiveC
import UIKit

// Associated object keys used to store properties on UIView. Swift extensions
// cannot add stored properties, so we use the Objective-C runtime instead.
private var badgeLabelKey: UInt8 = 0
private var badgeValueKey: UInt8 = 1
private var badgeVisibleKey: UInt8 = 2

private final class HoundBadgeLabel: UILabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = bounds.height / 2
        self.layer.masksToBounds = true
    }
}

/// Allows any UIView to display a small numeric badge in its top-right corner.
/// Set `badgeValue` to show a number or assign `nil` to hide the badge.
extension UIView {
    
    private var badgeLabel: HoundBadgeLabel? {
        // Stored via associated objects since extensions can't add properties.
        get { objc_getAssociatedObject(self, &badgeLabelKey) as? HoundBadgeLabel }
        set { objc_setAssociatedObject(self, &badgeLabelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var storedBadgeValue: Int? {
        // Backing storage for the public badgeValue property.
        get { objc_getAssociatedObject(self, &badgeValueKey) as? Int }
        set { objc_setAssociatedObject(self, &badgeValueKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var storedBadgeVisible: Bool {
        get { (objc_getAssociatedObject(self, &badgeVisibleKey) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &badgeVisibleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// Controls visibility of badge (text or empty)
    var badgeVisible: Bool {
        get { storedBadgeVisible }
        set {
            storedBadgeVisible = newValue
            updateBadgeAppearance()
        }
    }
    
    /// Value to display inside badge. Setting to nil means no text.
    var badgeValue: Int? {
        get { storedBadgeValue }
        set {
            storedBadgeValue = newValue
            updateBadgeAppearance()
        }
    }
    
    private func updateBadgeAppearance() {
        // If badge should ever be shown, ensure label exists
        if badgeVisible {
            createBadgeLabelIfNeeded()
            badgeLabel?.isHidden = false
            if let value = badgeValue {
                badgeLabel?.text = String(value)
            }
            else {
                badgeLabel?.text = nil // Show badge, but no text
            }
        }
        else {
            badgeLabel?.isHidden = true
        }
    }
    
    private func createBadgeLabelIfNeeded() {
        guard badgeLabel == nil else { return }
        
        let label = HoundBadgeLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = Constant.Visual.Font.badgeLabel
        
        label.backgroundColor = UIColor.houndYellow
        
        label.textColor = UIColor.label
        
        addSubview(label)
        
        // Square with side equal to min(0.2 * width, 0.2 * height)
        let ratio: CGFloat = 0.35
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            label.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: ratio).withPriority(.defaultHigh),
            label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: ratio).withPriority(.defaultHigh),
            label.createSquareAspectRatio()
        ])
        
        badgeLabel = label
    }
}
