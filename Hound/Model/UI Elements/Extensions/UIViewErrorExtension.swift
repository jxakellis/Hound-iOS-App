//
//  UIViewErrorExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/17/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

private var houndErrorLabelKey: UInt8 = 0

// both
private var originalBorderWidthKey: UInt8 = 1
private var originalBorderColorKey: UInt8 = 2

// hound stylable
private var originalShouldRoundCornersKey: UInt8 = 3

// non hound stylable
private var originalCornerRadiusKey: UInt8 = 4
private var originalCornerCurveKey: UInt8 = 5

extension UIView {

    /// Optional message describing an input error. Setting a non-nil value
    /// outlines the view in red and displays the message below it. Setting to
    /// `nil` removes the error UI.
    var errorMessage: String? {
        get {
            (objc_getAssociatedObject(self, &houndErrorLabelKey) as? HoundLabel)?.text
        }
        set {
            guard let message = newValue, message.isEmpty == false else {
                removeErrorMessage()
                return
            }
            showErrorMessage(message)
        }
    }

    private func showErrorMessage(_ message: String) {
        var label = objc_getAssociatedObject(self, &houndErrorLabelKey) as? HoundLabel
        if label == nil {
            let newLabel = HoundLabel()
            newLabel.font = VisualConstant.FontConstant.tertiaryRegularLabel
            newLabel.textColor = UIColor.systemRed
            newLabel.numberOfLines = 0
            newLabel.translatesAutoresizingMaskIntoConstraints = false
            objc_setAssociatedObject(self, &houndErrorLabelKey, newLabel, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            label = newLabel

            if let superview = self.superview {
                superview.addSubview(newLabel)
                NSLayoutConstraint.activate([
                    newLabel.topAnchor.constraint(equalTo: self.bottomAnchor),
                    newLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                    newLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
                ])
            }
        }

        label?.text = message
        label?.isHidden = false

        if objc_getAssociatedObject(self, &originalBorderWidthKey) == nil {
            objc_setAssociatedObject(self, &originalBorderWidthKey, layer.borderWidth, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        if let styleable = self as? HoundBorderStylable {
            if objc_getAssociatedObject(self, &originalBorderColorKey) == nil {
                objc_setAssociatedObject(self, &originalBorderColorKey, styleable.borderColor, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            if objc_getAssociatedObject(self, &originalShouldRoundCornersKey) == nil {
                objc_setAssociatedObject(self, &originalShouldRoundCornersKey, styleable.shouldRoundCorners, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        else {
            if objc_getAssociatedObject(self, &originalBorderColorKey) == nil, let layerBorderColor = layer.borderColor {
                // cannot encode CGColor
                objc_setAssociatedObject(self, &originalBorderColorKey, UIColor(cgColor: layerBorderColor), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            if objc_getAssociatedObject(self, &originalCornerRadiusKey) == nil {
                objc_setAssociatedObject(self, &originalCornerRadiusKey, layer.cornerRadius, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            if objc_getAssociatedObject(self, &originalCornerCurveKey) == nil {
                objc_setAssociatedObject(self, &originalCornerCurveKey, layer.cornerCurve, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }

        if let styleable = self as? (UIView & HoundBorderStylable) {
            styleable.applyStyle(.redBorder)
        }
        else {
            layer.borderColor = HoundBorderStyle.redBorder.borderColor.cgColor
            layer.borderWidth = HoundBorderStyle.redBorder.borderWidth
            layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius
            layer.cornerCurve = .continuous
        }
    }

    private func removeErrorMessage() {
        if let label = objc_getAssociatedObject(self, &houndErrorLabelKey) as? HoundLabel {
            label.removeFromSuperview()
            objc_setAssociatedObject(self, &houndErrorLabelKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        // Restore original border
        if let styleable = self as? HoundBorderStylable {
            styleable.borderWidth = objc_getAssociatedObject(self, &originalBorderWidthKey) as? CGFloat ?? styleable.borderWidth
            styleable.borderColor = objc_getAssociatedObject(self, &originalBorderColorKey) as? UIColor
            styleable.shouldRoundCorners = objc_getAssociatedObject(self, &originalShouldRoundCornersKey) as? Bool ?? styleable.shouldRoundCorners
        }
        else {
            layer.borderColor = (objc_getAssociatedObject(self, &originalBorderColorKey) as? UIColor)?.cgColor ?? layer.borderColor
            layer.borderWidth = objc_getAssociatedObject(self, &originalBorderWidthKey) as? CGFloat ?? layer.borderWidth
            layer.cornerRadius = objc_getAssociatedObject(self, &originalCornerRadiusKey) as? CGFloat ?? layer.cornerRadius
            layer.cornerCurve = objc_getAssociatedObject(self, &originalCornerCurveKey) as? CALayerCornerCurve ?? layer.cornerCurve
        }

        // Remove stored original border values
        objc_setAssociatedObject(self, &originalBorderColorKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &originalBorderWidthKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &originalBorderColorKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &originalShouldRoundCornersKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &originalCornerRadiusKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &originalCornerCurveKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
