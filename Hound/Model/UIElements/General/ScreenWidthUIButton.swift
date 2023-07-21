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
    
    enum SemiboldUIButtonStyles {
        case blackTextWhiteBackgroundBlackBorder
        case whiteTextBlueBackgroundNoBorder
        case whiteTextRedBackgroundNoBorder
    }
    
    private var style: SemiboldUIButtonStyles?
    
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
            self.applyStyle(forStyle: style)
        }
    }
    
    // MARK: - Functions
    
    /// Applied a predefined styles that dictate the look of the button's foreground, background, and border color.
    func applyStyle(forStyle style: SemiboldUIButtonStyles?) {
        self.style = style
        
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
        
        // If we have a style, apply the formatting
        if let style = style {
            switch style {
            case .blackTextWhiteBackgroundBlackBorder:
                self.setTitleColor(.black, for: .normal)
                self.backgroundColor = .white
                
                self.layer.borderWidth = VisualConstant.LayerConstant.boldBorderWidth
                self.layer.borderColor = VisualConstant.LayerConstant.whiteBackgroundBorderColor
            case .whiteTextBlueBackgroundNoBorder:
                self.setTitleColor(.white, for: .normal)
                self.backgroundColor = .systemBlue
                
                self.layer.borderWidth = VisualConstant.LayerConstant.noBorderWidth
                self.layer.borderColor = VisualConstant.LayerConstant.nonWhiteBackgroundBorderColor
            case .whiteTextRedBackgroundNoBorder:
                self.setTitleColor(.white, for: .normal)
                self.backgroundColor = .systemRed
                
                self.layer.borderWidth = VisualConstant.LayerConstant.noBorderWidth
                self.layer.borderColor = VisualConstant.LayerConstant.nonWhiteBackgroundBorderColor
            }
        }
        
    }

}
