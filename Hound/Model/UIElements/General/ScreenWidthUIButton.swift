//
//  ScreenWidthUIButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/12/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ScreenWidthUIButton: UIButton {

   // MARK: - Properties
    
    enum ScreenWidthUIButtonStyles {
        case blackTextWhiteBackgroundBlackBorder
        case whiteTextBlueBackgroundNoBorder
        case whiteTextRedBackgroundNoBorder
    }
    
    private var style: ScreenWidthUIButtonStyles?
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Resize corner radius when the ScreenWidthUIButton bounds change
    override var bounds: CGRect {
        didSet {
            if let style = style {
                self.applyStyle(forStyle: style)
            }
            else {
                self.applyNonStyle()
            }
        }
    }
    
    // MARK: - Functions
    
    /// Applied a predefined styles that dictate the look of the button's foreground, background, and border color.
    func applyStyle(forStyle style: ScreenWidthUIButtonStyles) {
        self.style = style
        
        applyNonStyle()
        
        switch style {
        case .blackTextWhiteBackgroundBlackBorder:
            self.setTitleColor(.black, for: .normal)
            self.backgroundColor = .white
            
            self.layer.borderWidth = VisualConstant.LayerConstant.blackTextWhiteBackgroundBorderWidth
            self.layer.borderColor = VisualConstant.LayerConstant.blackTextWhiteBackgroundBorderColor
        case .whiteTextBlueBackgroundNoBorder:
            self.setTitleColor(.white, for: .normal)
            self.backgroundColor = .systemBlue
            
            self.layer.borderWidth = VisualConstant.LayerConstant.whiteTextBlueBackgroundBorderWidth
            self.layer.borderColor = VisualConstant.LayerConstant.whiteTextBlueBackgroundBorderColor
        case .whiteTextRedBackgroundNoBorder:
            self.setTitleColor(.white, for: .normal)
            self.backgroundColor = .systemRed
            
            self.layer.borderWidth = VisualConstant.LayerConstant.whiteTextRedBackgroundBorderWidth
            self.layer.borderColor = VisualConstant.LayerConstant.whiteTextRedBackgroundBorderColor
        }
    }
    
    /// Applies styling that isn't dependent upon the style
    private func applyNonStyle() {
        if let attributedText = self.titleLabel?.attributedText {
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedString.addAttribute(
                NSAttributedString.Key.font,
                value: VisualConstant.FontConstant.semiboldScreenWidthButton,
                range: NSRange(location: 0, length: attributedText.length)
            )
            self.setAttributedTitle(mutableAttributedString, for: .normal)
        }
        else {
            self.titleLabel?.font = VisualConstant.FontConstant.semiboldScreenWidthButton
        }
        
        self.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        self.layer.cornerRadius = self.bounds.height / 2
    }

}
