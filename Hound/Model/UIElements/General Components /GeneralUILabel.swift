//
//  GeneralUILabel.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/3/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class GeneralUILabel: UILabel, GeneralUIProtocol {
    
    // MARK: - GeneralUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]

    // MARK: - Properties
    
    /// If shouldRoundCorners == true, then this variable dictates the cornerRadius.If true, then cornerRadius = self.bounds.height / 2.0. If false, cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius.
    var isRoundingToCircle: Bool = false {
        didSet {
            self.updateCornerRoundingIfNeeded()
        }
    }

    private var hasAdjustedShouldRoundCorners: Bool = false
    /// If true, the corners of the view are rounded, depending upon the value of isRoundingToCircle. If false, cornerRadius = 0.
    var shouldRoundCorners: Bool = false {
        didSet {
            self.hasAdjustedShouldRoundCorners = true
            self.updateCornerRoundingIfNeeded()
        }
    }

    var borderWidth: Double {
        get {
            Double(self.layer.borderWidth)
        }
        set {
            self.layer.borderWidth = CGFloat(newValue)
        }
    }

    var borderColor: UIColor? {
        didSet {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
            }
        }
    }

    private let placeholderLabelSpacing: String = "  "
    private var placeholderLabel: UILabel?
    /// placeholder is a second GeneralUILabel that is added as a subview to this GeneralUILabel. It acts as temporary inlaid text until an actual value is input
    var placeholder: String? {
        get {
            var placeholderText: String?

            if let placeholderLabel = placeholderLabel {
                var withRemovedPadding = placeholderLabel.text
                withRemovedPadding?.removeFirst(2)
                placeholderText = withRemovedPadding
            }

            return placeholderText
        }
        set {
            guard let placeholderLabel = placeholderLabel else {
                // We do not have a placeholderLabel yet
                if let newValue = newValue {
                    // Because this is our first time making a placeholderLabel, text doesn't have the two space padding on the front of it. We do this step first because if we set self.placeholderLabel to something that isn't nil, the special logic for text starts (which removes the first two characters).
                    if let text = self.text {
                        self.text = placeholderLabelSpacing.appending(text)
                    }

                    // We have placeholder text, so make a placeholderLabel
                    let placeholderLabel = UILabel()

                    placeholderLabel.text = placeholderLabelSpacing.appending(newValue)
                    placeholderLabel.sizeToFit()

                    placeholderLabel.font = self.font
                    placeholderLabel.textColor = UIColor.placeholderText
                    self.placeholderLabel = placeholderLabel

                    self.updatePlaceholderLabelIsHidden()

                    self.addSubview(placeholderLabel)
                    self.updatePlaceholderLabelFrame()
                }

                return
            }

            // We have a placeholderLabel, update it's text
            if let newValue = newValue {
                // add two space offset to placeholder label.
                placeholderLabel.text = placeholderLabelSpacing.appending(newValue)
            }
            else {
                placeholderLabel.text = nil
            }

            placeholderLabel.sizeToFit()
        }
    }

    /// When set, this closure will create the NSAttributedString for attributedText and set attributedTet equal to that. This is necessary because attributedText doesn't support dynamic colors and therefore doesn't change its colors when the UITraitCollection updates. Additionally, this closure is invoke when the UITraitCollection updates to manually make the attributedText support dynamic colors
    var attributedTextClosure: (() -> NSAttributedString)? {
        didSet {
            if let attributedText = attributedTextClosure?() {
                self.attributedText = attributedText
            }
        }
    }

    // MARK: - Override Properties

    override var bounds: CGRect {
        didSet {
            super.bounds = bounds
            self.updatePlaceholderLabelFrame()
        }
    }

    override var text: String? {
        get {
            var text = super.text
            if placeholder != nil {
                text?.removeFirst(2)
            }
            return text
        }
        set {
            if let newValue = newValue {
                super.text = placeholder != nil ? placeholderLabelSpacing.appending(newValue) : newValue
            }
            else {
                super.text = nil
            }

            guard let placeholderLabel = placeholderLabel else {
                return
            }

            guard let placeholderLabelText = placeholderLabel.text, placeholderLabelText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
                placeholderLabel.isHidden = true
                return
            }

            updatePlaceholderLabelIsHidden()
        }
    }

    override var isEnabled: Bool {
        didSet {
            // Make sure to incur didSet of superclass
            super.isEnabled = isEnabled
            self.alpha = isEnabled ? 1 : 0.5
        }
    }

    // MARK: - Main
    
    init(huggingPriority: Float = UILayoutPriority.defaultLow.rawValue, compressionResistancePriority: Float = UILayoutPriority.defaultLow.rawValue) {
        super.init(frame: .zero)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .vertical)
        self.applyDefaultSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyDefaultSetup(constraintBasedLayout: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    // MARK: - Override Functions

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
            }
            if let attributedText = attributedTextClosure?() {
                self.attributedText = attributedText
            }
        }
    }

    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.contentMode = .left
        self.textAlignment = .natural
        self.lineBreakMode = .byTruncatingTail
        self.baselineAdjustment = .alignBaselines
        self.adjustsFontSizeToFitWidth = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.minimumScaleFactor = 0.875
        
        SizeDebugView.install(on: self)
        
        updateCornerRoundingIfNeeded()
    }

    private func updateCornerRoundingIfNeeded() {
        if self.hasAdjustedShouldRoundCorners == true {
            if shouldRoundCorners {
                self.layer.masksToBounds = true
            }
            
            let cornerRadiusIfRounding = isRoundingToCircle ? self.bounds.height / 2.0 : VisualConstant.LayerConstant.defaultCornerRadius
            self.layer.cornerRadius = shouldRoundCorners ? cornerRadiusIfRounding : 0.0
            self.layer.cornerCurve = .continuous
        }
    }

    private func updatePlaceholderLabelFrame() {
        placeholderLabel?.frame = self.bounds
    }

    private func updatePlaceholderLabelIsHidden() {
        // If text isn't nil and has a non-empty string, we want to hide the placeholder (since the place it was holding for now has text in it)
        placeholderLabel?.isHidden = self.text != nil && self.text?.trimmingCharacters(in: .whitespaces).isEmpty == false
    }
}
