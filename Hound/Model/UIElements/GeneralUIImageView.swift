//
//  GeneralUIImageView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

@IBDesignable final class GeneralUIImageView: UIImageView, GeneralUIProtocol {
    
    // MARK: - GeneralUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]

    // MARK: - Properties

    private var hasAdjustedShouldRoundCorners: Bool = false
    /// If true, self.layer.cornerRadius = self.bounds.height / 2 is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    @IBInspectable var shouldRoundCorners: Bool = false {
        didSet {
            self.hasAdjustedShouldRoundCorners = true
            self.updateCornerRoundingIfNeeded()
        }
    }

    /// If true, self.layer.cornerRadius = self.bounds.height / 2 is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    @IBInspectable var shouldScaleImagePointSize: Bool = false {
        didSet {
            self.updateScaleImagePointSizeIfNeeded()
        }
    }

    // MARK: - Override Properties

    /// Resize corner radius when the bounds change
    override var bounds: CGRect {
        didSet {
            // Make sure to incur didSet of superclass
            super.bounds = bounds
            self.updateCornerRoundingIfNeeded()
            self.updateScaleImagePointSizeIfNeeded()
        }
    }

    override var image: UIImage? {
        didSet {
            // Make sure to incur didSet of superclass
            super.image = image
            self.updateScaleImagePointSizeIfNeeded()
        }
    }

    override var isUserInteractionEnabled: Bool {
        didSet {
            // Make sure to incur didSet of superclass
            super.isUserInteractionEnabled = isUserInteractionEnabled
            self.alpha = isUserInteractionEnabled ? 1 : 0.5
        }
    }

    // MARK: - Main

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.updateCornerRoundingIfNeeded()
        self.updateScaleImagePointSizeIfNeeded()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.updateCornerRoundingIfNeeded()
        self.updateScaleImagePointSizeIfNeeded()
    }

    // MARK: - Functions

    private func updateCornerRoundingIfNeeded() {
        if self.hasAdjustedShouldRoundCorners == true {
            if shouldRoundCorners {
                self.layer.masksToBounds = true
            }
            self.layer.cornerRadius = shouldRoundCorners ? self.bounds.height / 2.0 : 0.0
            self.layer.cornerCurve = .continuous
        }
    }

    /// If there is a current, symbol image, scales its point size to the smallest dimension of bounds
    private func updateScaleImagePointSizeIfNeeded() {
        guard shouldScaleImagePointSize else {
            return
        }

        guard let image = image, image.isSymbolImage == true else {
            return
        }

        let smallestDimension = bounds.height <= bounds.width ? bounds.height : bounds.width

        super.image = image.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: smallestDimension))
    }

}
