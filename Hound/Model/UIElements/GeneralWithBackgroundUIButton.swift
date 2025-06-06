//
//  GeneralWithBackgroundUIButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/23/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class GeneralWithBackgroundUIButton: GeneralUIButton {

    // MARK: - Properties

    var backgroundUIButtonTintColor: UIColor? {
        didSet {
            backgroundGeneralUIButton?.tintColor = backgroundUIButtonTintColor
        }
    }

    private var backgroundGeneralUIButton: GeneralUIButton?

    // MARK: - Override Properties

    /// If GeneralWithBackgroundUIButton has its bounds changed, its backgroundScaledImage might need re-scaled
    override var bounds: CGRect {
        didSet {
            // Make sure to incur didSet of superclass
            super.bounds = bounds
            updateBackgroundGeneralUIButton()
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
        updateBackgroundGeneralUIButton()
    }

    /// As soon as GeneralWithBackgroundUIButton is established, its backgroundScaledImage will need established
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateBackgroundGeneralUIButton()
    }

    // MARK: - Functions

    private func updateBackgroundGeneralUIButton() {
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
            backgroundGeneralUIButton?.setImage(UIImage.init(systemName: "circle.fill"), for: .normal)
            backgroundGeneralUIButton?.tintColor = backgroundUIButtonTintColor
            backgroundGeneralUIButton?.isUserInteractionEnabled = false
            
            if let backgroundGeneralUIButton = backgroundGeneralUIButton {
                insertSubview(backgroundGeneralUIButton, belowSubview: imageView ?? UIView())
            }

            // Now that backgroundGeneralUIButton isn't nil, reinvoke this function to fix it.
            updateBackgroundGeneralUIButton()
            return
        }

        backgroundGeneralUIButton.frame = adjustedBounds
    }

}
