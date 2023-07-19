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
            self.titleLabel?.textColor = .red
            self.backgroundColor = .white
            
            self.layer.borderWidth = VisualConstant.LayerConstant.screenWidthUIButtonBlackTextWhiteBackgroundBlackBorderBorderWidth
            self.layer.borderColor = VisualConstant.LayerConstant.screenWidthUIButtonBlackTextWhiteBackgroundBlackBorderBorderColor
        case .whiteTextBlueBackgroundNoBorder:
            self.titleLabel?.textColor = .white
            self.backgroundColor = .systemBlue
            
            self.layer.borderWidth = VisualConstant.LayerConstant.screenWidthUIButtonWhiteTextBlueBackgroundNoBorderBorderWidth
            self.layer.borderColor = VisualConstant.LayerConstant.screenWidthUIButtonWhiteTextBlueBackgroundNoBorderBorderColor
        case .whiteTextRedBackgroundNoBorder:
            self.titleLabel?.textColor = .white
            self.backgroundColor = .systemRed
            
            self.layer.borderWidth = VisualConstant.LayerConstant.screenWidthUIButtonWhiteTextRedBackgroundNoBorderBorderWidth
            self.layer.borderColor = VisualConstant.LayerConstant.screenWidthUIButtonWhiteTextRedBackgroundNoBorderBorderColor
        }
    }
    
    // Applies factors that aren't dependent upon the style
    private func applyNonStyle() {
        self.titleLabel?.font = VisualConstant.FontConstant.semiboldScreenWidthUIButton
        
        self.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        self.layer.cornerRadius = self.bounds.height / 2
        
    }

}
