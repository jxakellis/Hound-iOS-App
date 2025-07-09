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

    /// A numeric value displayed in a small badge at the top right of the view.
    /// Setting this to `nil` hides the badge.
    var badgeValue: Int? {
        get { storedBadgeValue }
        set {
            storedBadgeValue = newValue
            if let value = newValue {
                showBadge(withValue: value)
            }
            else {
                badgeLabel?.isHidden = true
            }
        }
    }

    private func showBadge(withValue value: Int) {
        createBadgeLabelIfNeeded()
        badgeLabel?.text = String(value)
        badgeLabel?.isHidden = false
    }

    private func createBadgeLabelIfNeeded() {
        guard badgeLabel == nil else { return }

        let label = HoundBadgeLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = VisualConstant.FontConstant.badgeLabel
        
        label.backgroundColor = UIColor.houndYellow
        
        label.textColor = UIColor.label

        addSubview(label)

        // Position in the top-right corner
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

        // Square with side equal to min(0.2 * width, 0.2 * height)
        let ratio: CGFloat = 0.35
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: ratio).withPriority(.defaultHigh),
            label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: ratio).withPriority(.defaultHigh),
            label.createSquareAspectRatio()
        ])
        
        badgeLabel = label
    }
}
