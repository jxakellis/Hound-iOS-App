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
    }
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Functions
    
    // A ScreenWidthUIButton has a number of predefined styles that dictate what it looks like. This generally only impacts its foreground, background, and border color.
    func applyStyle(forStyle style: ScreenWidthUIButtonStyles) {
        self.titleLabel?.font = VisualConstant.FontConstant.screenWidthUIButton
        
        self.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        self.layer.cornerRadius = self.frame.height / 2
        
        switch style {
        case .blackTextWhiteBackgroundBlackBorder:
            self.titleLabel?.textColor = .black
            self.backgroundColor = .white
            
            self.layer.borderWidth = VisualConstant.LayerConstant.screenWidthUIButtonBlackTextWhiteBackgroundBlackBorderBorderWidth
            self.layer.borderColor = VisualConstant.LayerConstant.screenWidthUIButtonBlackTextWhiteBackgroundBlackBorderBorderColor
        case .whiteTextBlueBackgroundNoBorder:
            self.titleLabel?.textColor = .white
            self.backgroundColor = .systemBlue
            
            self.layer.borderWidth = VisualConstant.LayerConstant.screenWidthUIButtonWhiteTextBlueBackgroundNoBorderBorderWidth
            self.layer.borderColor = VisualConstant.LayerConstant.screenWidthUIButtonWhiteTextBlueBackgroundNoBorderBorderColor

        }
    }

}
