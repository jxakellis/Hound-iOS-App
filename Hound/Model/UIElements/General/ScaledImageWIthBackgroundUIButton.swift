//
//  ScaledImageWithBackgroundUIButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/23/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

@IBDesignable class ScaledImageWithBackgroundUIButton: ScaledImageUIButton {
    
    // MARK: - Properties
    
    private var storedBackgroundUIButtonTintColor: UIColor?
    @IBInspectable var backgroundUIButtonTintColor: UIColor? {
        didSet {
            storedBackgroundUIButtonTintColor = backgroundUIButtonTintColor
            backgroundScaledImageUIButton?.tintColor = backgroundUIButtonTintColor
        }
    }
    
    private var backgroundScaledImageUIButton: ScaledImageUIButton?
    
    /// If ScaledImageWithBackgroundUIButton has its bounds changed, its backgroundScaledImage might need re-scaled
    override var bounds: CGRect {
        didSet {
            // Make sure to incur didSet of superclass
            super.bounds = bounds
            scaleBackgroundScaledImageUIButton()
        }
    }
    
    override var isHidden: Bool {
        didSet {
            // Make sure to incur didSet of superclass
            super.isHidden = isHidden
            backgroundScaledImageUIButton?.isHidden = isHidden
        }
    }
    
    // MARK: - Main
    
    /// As soon as ScaledImageWithBackgroundUIButton is established, its backgroundScaledImage will need established
    override init(frame: CGRect) {
        super.init(frame: frame)
        scaleBackgroundScaledImageUIButton()
    }
    
    /// As soon as ScaledImageWithBackgroundUIButton is established, its backgroundScaledImage will need established
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        scaleBackgroundScaledImageUIButton()
    }
    
    // MARK: - Functions
    
    private func scaleBackgroundScaledImageUIButton() {
        let multiplier = 1.05
        let width = bounds.width / multiplier
        let height = bounds.height / multiplier
        let adjustedBounds = CGRect(
            x: (bounds.width / 2.0) - (width / 2),
            y: (bounds.height / 2.0) - (height / 2),
            width: width,
            height: height)
        
        guard let backgroundScaledImageUIButton = backgroundScaledImageUIButton else {
            backgroundScaledImageUIButton = ScaledImageUIButton(frame: adjustedBounds)
            backgroundScaledImageUIButton?.setImage(UIImage.init(systemName: "circle.fill"), for: .normal)
            backgroundScaledImageUIButton?.tintColor = storedBackgroundUIButtonTintColor ?? .systemPink
            backgroundScaledImageUIButton?.isUserInteractionEnabled = false
            if let backgroundScaledImageUIButton = backgroundScaledImageUIButton {
                insertSubview(backgroundScaledImageUIButton, belowSubview: imageView ?? UIView())
            }
            scaleBackgroundScaledImageUIButton()
            return
        }
        
        backgroundScaledImageUIButton.frame = adjustedBounds
    }
    
}
