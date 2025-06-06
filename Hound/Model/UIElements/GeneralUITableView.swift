//
//  GeneralUITableView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/29/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class GeneralUITableView: UITableView, GeneralUIProtocol {
    
    // MARK: - GeneralUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]
    
    // MARK: - Properties

    var shouldAutomaticallyAdjustHeight: Bool = false {
        didSet {
            if shouldAutomaticallyAdjustHeight {
                self.invalidateIntrinsicContentSize()
                self.layoutIfNeeded()
            }
        }
    }

    private var hasAdjustedShouldRoundCorners: Bool = false
    /// If true, VisualConstant.LayerConstant.defaultCornerRadius is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    var shouldRoundCorners: Bool = false {
        didSet {
            self.hasAdjustedShouldRoundCorners = true
            self.updateCornerRoundingIfNeeded()
        }
    }

    var borderWidth: Double {
        get {
            Double(self.layer.borderWidth)
        }
        set {
            self.layer.borderWidth = CGFloat(newValue)
        }
    }

    var borderColor: UIColor? {
        didSet {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
            }
        }
    }

    var shadowColor: UIColor? {
        didSet {
            if let shadowColor = shadowColor {
                self.layer.shadowColor = shadowColor.cgColor
            }
        }
    }

    var shadowOffset: CGSize? {
        didSet {
            if let shadowOffset = shadowOffset {
                self.layer.shadowOffset = shadowOffset
            }
        }
    }

    var shadowRadius: CGFloat? {
        didSet {
            if let shadowRadius = shadowRadius {
                self.layer.shadowRadius = shadowRadius
            }
        }
    }

    var shadowOpacity: Float? {
        didSet {
            if let shadowOpacity = shadowOpacity {
                self.layer.shadowOpacity = shadowOpacity
            }
        }
    }

    // MARK: - Override Properties

    override var intrinsicContentSize: CGSize {
        if shouldAutomaticallyAdjustHeight {
            self.layoutIfNeeded()
            return self.contentSize
        }
        else {
            return super.intrinsicContentSize
        }
    }

    override var contentSize: CGSize {
        didSet {
            // Make sure to incur didSet of superclass
            super.contentSize = contentSize
            if shouldAutomaticallyAdjustHeight {
                self.invalidateIntrinsicContentSize()
            }
        }
    }

    override var bounds: CGRect {
        didSet {
            // Make sure to incur didSet of superclass
            super.bounds = bounds
            updateCornerRoundingIfNeeded()
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
    
    init(huggingPriority: Float = 250, compressionResistancePriority: Float = 750) {
        super.init(frame: .zero, style: .plain)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .vertical)
        self.applyDefaultSetup()
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        applyDefaultSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyDefaultSetup()
    }
    
    // MARK: - Override Functions
    
    private func applyDefaultSetup() {
        // TODO find default properites
        
        updateCornerRoundingIfNeeded()
    }

    override func reloadData() {
        super.reloadData()
        if shouldAutomaticallyAdjustHeight {
            self.invalidateIntrinsicContentSize()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
            }
            if let shadowColor = shadowColor {
                self.layer.shadowColor = shadowColor.cgColor
            }
        }
    }

    // MARK: - Functions

    private func updateCornerRoundingIfNeeded() {
        if self.hasAdjustedShouldRoundCorners == true {
            if shouldRoundCorners {
                self.layer.masksToBounds = true
            }
            self.layer.cornerRadius = shouldRoundCorners ? VisualConstant.LayerConstant.defaultCornerRadius : 0.0
            self.layer.cornerCurve = .continuous
        }
    }

}
