//
//  GeneralUILabel.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/3/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class GeneralUILabel: ScaledUILabel {
    
    // MARK: - Properties
    
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
    
    override var text: String? {
        get {
            // remove 2 space offset before returning
            var withRemovedPadding = super.text
            withRemovedPadding?.removeFirst(2)
            return withRemovedPadding
        }
        set {
            
            if let newValue = newValue {
                // add 2 space offset
                super.text = "  ".appending(newValue)
            }
            else {
                // set bordered label text
                super.text = nil
            }
            
            self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForGeneralUILabel)
            // Ensure the placeholderLabel exists
            guard let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForGeneralUILabel) as? UILabel else {
                return
            }
            
            // Ensure placeholderLabel text exists and isn't ""
            guard let placeholderLabelText = placeholderLabel.text, placeholderLabelText.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                placeholderLabel.isHidden = true
                return
            }
            
            togglePlaceholderLabelIsHidden(forPlaceholderLabel: placeholderLabel)
        }
    }
    
    /// Resize the placeholder when the ScaledUILabel bounds change
    override var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The ScaledUILabel placeholder text
    var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForGeneralUILabel) as? ScaledUILabel {
                var withRemovedPadding = placeholderLabel.text
                withRemovedPadding?.removeFirst(2)
                placeholderText = withRemovedPadding
            }
            
            return placeholderText
        }
        set {
            guard let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForGeneralUILabel) as? ScaledUILabel else {
                // need to make placeholder label
                if let newValue = newValue {
                    self.addPlaceholder("  ".appending(newValue))
                }
                return
            }
            
            if let newValue = newValue {
                // add two space offset to placeholder label.
                placeholderLabel.text = "  ".appending(newValue)
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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.layer.borderColor = storedBorderColor?.cgColor
        }
    }
    
    // MARK: - Functions
    
    /// Resize the placeholder ScaledUILabel to make sure it's in the same position as the ScaledUILabel text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForGeneralUILabel) as? ScaledUILabel {
            placeholderLabel.frame = self.bounds
        }
    }
    
    /// Adds a placeholder ScaledUILabel to this ScaledUILabel
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = ScaledUILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.systemGray3
        placeholderLabel.tag = VisualConstant.ViewTagConstant.placeholderLabelForGeneralUILabel
        
        togglePlaceholderLabelIsHidden(forPlaceholderLabel: placeholderLabel)
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
    }
    
    /// Changes the isHidden status of the placeholderLabel passed, based upon the presence and contents of self.text
    private func togglePlaceholderLabelIsHidden(forPlaceholderLabel placeholderLabel: UILabel) {
        if let labelText = self.text {
            // If the text of the ui label exists, then we want to hide the placeholder label (if the ui label text contains actual characters)
            // "anyText" != "" -> true -> hide the placeholder label
            // "" != "" -> false -> show the placeholder label
            placeholderLabel.isHidden = labelText.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        }
        // If the primary text of UILabel is nil, then show the placeholder label!
        else {
            placeholderLabel.isHidden = false
        }
    }
}
