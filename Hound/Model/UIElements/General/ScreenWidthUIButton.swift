//
//  SemiboldUIButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/12/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SemiboldUIButton: GeneralUIButton {
    
    // MARK: - Properties
    
    @IBInspectable var titleLabelTextColor: UIColor? {
        get {
            return self.titleLabel?.textColor
        }
        set {
            self.setTitleColor(newValue, for: .normal)
        }
    }
    
    @IBInspectable var buttonBackgroundColor: UIColor? {
        get {
            return self.backgroundColor
        }
        set {
            self.backgroundColor = newValue
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
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // SemiboldUIButton should always have rounded corners
        shouldRoundCorners = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // SemiboldUIButton should always have rounded corners
        shouldRoundCorners = true
    }
    
    /// Resize corner radius when the SemiboldUIButton bounds change
    override var bounds: CGRect {
        didSet {
            // Make sure to incur didSet of superclass
            super.bounds = bounds
            
            /// Make the titleLabel's font .semiboldButton, whether text or attributedText.
            if let attributedText = self.titleLabel?.attributedText {
                let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
                mutableAttributedString.addAttribute(
                    NSAttributedString.Key.font,
                    value: VisualConstant.FontConstant.semiboldButton,
                    range: NSRange(location: 0, length: attributedText.length)
                )
                self.setAttributedTitle(mutableAttributedString, for: .normal)
            }
            else {
                self.titleLabel?.font = VisualConstant.FontConstant.semiboldButton
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            layer.borderColor = storedBorderColor?.cgColor
        }
    }
    
}
