//
//  GeneralUILabel.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/3/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

@IBDesignable final class GeneralUILabel: UILabel {
    
    // MARK: - Properties
    
    private var storedShouldAdjustScaleFactor: Bool = true
    @IBInspectable var shouldAdjustScaleFactor: Bool {
        get {
            return storedShouldAdjustScaleFactor
        }
        set {
            storedShouldAdjustScaleFactor = newValue
            if shouldAdjustScaleFactor {
                adjustScaleFactor()
            }
        }
    }
    
    /// If true, self.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius. Otherwise, self.layer.cornerRadius = 0.
    private var storedShouldRoundCorners: Bool = false
    /// If true, self.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius. Otherwise, self.layer.cornerRadius = 0.
    @IBInspectable var shouldRoundCorners: Bool {
        get {
            return storedShouldRoundCorners
        }
        set {
            storedShouldRoundCorners = newValue
            self.layer.cornerRadius = newValue ? VisualConstant.LayerConstant.defaultCornerRadius : 0.0
            self.layer.masksToBounds = newValue
            self.layer.cornerCurve = .continuous
        }
    }
    
    @IBInspectable var borderWidth: Double {
        get {
            return Double(self.layer.borderWidth)
        }
        set {
            self.layer.borderWidth = CGFloat(newValue)
        }
    }
    
    private var storedBorderColor: UIColor?
    @IBInspectable var borderColor: UIColor? {
        get {
            return storedBorderColor
        }
        set {
            self.storedBorderColor = newValue
            self.layer.borderColor = newValue?.cgColor
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
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if shouldAdjustScaleFactor {
            adjustScaleFactor()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        if shouldAdjustScaleFactor {
            adjustScaleFactor()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.layer.borderColor = storedBorderColor?.cgColor
        }
    }
    
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
            
            guard let placeholderLabelText = placeholderLabel.text, placeholderLabelText.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                placeholderLabel.isHidden = true
                return
            }
            
            updatePlaceholderLabelIsHidden()
        }
    }
    
    // MARK: - Functions
    
    private func adjustScaleFactor() {
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.75
    }
    
    private func updatePlaceholderLabelFrame() {
        placeholderLabel?.frame = self.bounds
    }
    
    private func updatePlaceholderLabelIsHidden() {
        // If text isn't nil and has a non-empty string, we want to hide the placeholder (since the place it was holding for now has text in it)
        placeholderLabel?.isHidden = self.text != nil && self.text?.trimmingCharacters(in: .whitespaces) != ""
    }
}
