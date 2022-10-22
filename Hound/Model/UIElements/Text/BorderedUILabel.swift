//
//  BorderedUILabel.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/3/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class BorderedUILabel: ScaledUILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.2
        self.layer.borderColor = UIColor.systemGray2.cgColor
        self.layer.cornerRadius = 5.0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.2
        self.layer.borderColor = UIColor.systemGray2.cgColor
        self.layer.cornerRadius = 5.0
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
            
            self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForBorderedUILabel)
            // Ensure the placeholderLabel exists
            guard let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForBorderedUILabel) as? UILabel else {
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
            
            if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForBorderedUILabel) as? ScaledUILabel {
                var withRemovedPadding = placeholderLabel.text
                withRemovedPadding?.removeFirst(2)
                placeholderText = withRemovedPadding
            }
            
            return placeholderText
        }
        set {
            guard let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForBorderedUILabel) as? ScaledUILabel else {
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
    
    /// Resize the placeholder ScaledUILabel to make sure it's in the same position as the ScaledUILabel text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForBorderedUILabel) as? ScaledUILabel {
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
        placeholderLabel.tag = VisualConstant.ViewTagConstant.placeholderLabelForBorderedUILabel
        
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
