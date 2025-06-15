//
//  GeneralUIImageView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class GeneralUIImageView: UIImageView, GeneralUIProtocol {
    
    // MARK: - GeneralUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]
    
    // MARK: - Properties
    
    private var hasAdjustedShouldRoundCorners: Bool = false
    /// If true, self.layer.cornerRadius = self.bounds.height / 2 is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    var shouldRoundCorners: Bool = false {
        didSet {
            self.hasAdjustedShouldRoundCorners = true
            self.updateCornerRoundingIfNeeded()
        }
    }
    
    // MARK: - Override Properties
    
    /// Resize corner radius when the bounds change
    override var bounds: CGRect {
        didSet {
            // Make sure to incur didSet of superclass
            super.bounds = bounds
            self.updateCornerRoundingIfNeeded()
            self.updateScaleImagePointSize()
        }
    }
    
    override var image: UIImage? {
        didSet {
            // Make sure to incur didSet of superclass
            super.image = image
            self.updateScaleImagePointSize()
        }
    }
    
    var shouldAutoAdjustAlpha = false {
        didSet {
            guard let preAdjustmentAlpha = preAdjustmentAlpha else {
                return
            }
            
            // adjust super.alpha to avoid triggering our self.alpha override
            super.alpha = preAdjustmentAlpha
            self.preAdjustmentAlpha = nil
        }
    }
    private var preAdjustmentAlpha: CGFloat?
    override var isUserInteractionEnabled: Bool {
        didSet {
            // Make sure to incur didSet of superclass
            super.isUserInteractionEnabled = isUserInteractionEnabled
            if shouldAutoAdjustAlpha {
                if preAdjustmentAlpha == nil {
                    preAdjustmentAlpha = alpha
                }
                // adjust super.alpha to avoid triggering our self.alpha override
                super.alpha = isUserInteractionEnabled ? 1 : 0.5
            }
        }
    }
    
    override var alpha: CGFloat {
        didSet {
            super.alpha = alpha
            self.preAdjustmentAlpha = alpha
        }
    }
    
    // MARK: - Main
    
    init(huggingPriority: Float = 250, compressionResistancePriority: Float = 250) {
        super.init(frame: .zero)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .vertical)
        self.applyDefaultSetup()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.applyDefaultSetup()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        self.applyDefaultSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyDefaultSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFit
        self.translatesAutoresizingMaskIntoConstraints = false
        
        updateCornerRoundingIfNeeded()
        updateScaleImagePointSize()
    }
    
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
    private func updateScaleImagePointSize() {
        guard let image = image, image.isSymbolImage == true else {
            return
        }
        
        let smallestDimension = bounds.height <= bounds.width ? bounds.height : bounds.width
        
        super.image = image.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: smallestDimension))
    }
    
}
