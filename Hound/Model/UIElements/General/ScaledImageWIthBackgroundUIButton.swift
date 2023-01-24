//
//  ScaledImageWIthBackgroundUIButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/23/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ScaledImageWIthBackgroundUIButton: ScaledImageUIButton {

    // MARK: - Properties
    
    private var backgroundScaledImageUIButton: ScaledImageUIButton?
    
    override var bounds: CGRect {
        didSet {
            scaleBackgroundScaledImageUIButton()
        }
    }
    
    override var isHidden: Bool {
        didSet {
            backgroundScaledImageUIButton?.isHidden = isHidden
        }
    }
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scaleBackgroundScaledImageUIButton()
    }
        
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
            backgroundScaledImageUIButton?.tintColor = .white
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
