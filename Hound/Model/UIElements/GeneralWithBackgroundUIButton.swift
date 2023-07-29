//
//  GeneralWithBackgroundUIButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/23/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

@IBDesignable final class GeneralWithBackgroundUIButton: GeneralUIButton {
    
    // MARK: - Properties
    
    private var storedBackgroundUIButtonTintColor: UIColor?
    @IBInspectable var backgroundUIButtonTintColor: UIColor? {
        get {
            return storedBackgroundUIButtonTintColor
        }
        set {
            storedBackgroundUIButtonTintColor = newValue
            backgroundGeneralUIButton?.tintColor = backgroundUIButtonTintColor
        }
    }
    
    private var backgroundGeneralUIButton: GeneralUIButton?
    
    /// If GeneralWithBackgroundUIButton has its bounds changed, its backgroundScaledImage might need re-scaled
    override var bounds: CGRect {
        didSet {
            // Make sure to incur didSet of superclass
            super.bounds = bounds
            scaleBackgroundGeneralUIButton()
        }
    }
    
    override var isHidden: Bool {
        didSet {
            // Make sure to incur didSet of superclass
            super.isHidden = isHidden
            backgroundGeneralUIButton?.isHidden = isHidden
        }
    }
    
    // MARK: - Main
    
    /// As soon as GeneralWithBackgroundUIButton is established, its backgroundScaledImage will need established
    override init(frame: CGRect) {
        super.init(frame: frame)
        scaleBackgroundGeneralUIButton()
    }
    
    /// As soon as GeneralWithBackgroundUIButton is established, its backgroundScaledImage will need established
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        scaleBackgroundGeneralUIButton()
    }
    
    // MARK: - Functions
    
    private func scaleBackgroundGeneralUIButton() {
        let multiplier = 1.05
        let width = bounds.width / multiplier
        let height = bounds.height / multiplier
        let adjustedBounds = CGRect(
            x: (bounds.width / 2.0) - (width / 2),
            y: (bounds.height / 2.0) - (height / 2),
            width: width,
            height: height)
        
        guard let backgroundGeneralUIButton = backgroundGeneralUIButton else {
            backgroundGeneralUIButton = GeneralUIButton(frame: adjustedBounds)
            backgroundGeneralUIButton?.shouldScaleImagePointSize = true
            backgroundGeneralUIButton?.setImage(UIImage.init(systemName: "circle.fill"), for: .normal)
            backgroundGeneralUIButton?.tintColor = storedBackgroundUIButtonTintColor ?? .systemPink
            backgroundGeneralUIButton?.isUserInteractionEnabled = false
            if let backgroundGeneralUIButton = backgroundGeneralUIButton {
                insertSubview(backgroundGeneralUIButton, belowSubview: imageView ?? UIView())
            }
            scaleBackgroundGeneralUIButton()
            return
        }
        
        backgroundGeneralUIButton.frame = adjustedBounds
    }
    
}
