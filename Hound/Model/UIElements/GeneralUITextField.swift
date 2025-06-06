//
//  GeneralUITextField.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/30/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

@IBDesignable final class GeneralUITextField: UITextField, GeneralUIProtocol {
    
    // MARK: - GeneralUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]

    // MARK: - Properties

    private var hasAdjustedShouldRoundCorners: Bool = false
    /// If true, self.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius. Otherwise, self.layer.cornerRadius = 0.
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

    // MARK: - Override Properties

    override var isEnabled: Bool {
        didSet {
            // Make sure to incur didSet of superclass
            super.isEnabled = isEnabled
            self.alpha = isEnabled ? 1 : 0.5
        }
    }

    // MARK: - Main
    
    init(
        huggingPriority: Float = 250,
        compressionResistencePriority: Float = 750
    ) {
        super.init(frame: .zero)
        
        
        // TODO restore these properties to generaluitextfield
//        self.font = .systemFont(ofSize: 17.5)
//        self.minimumFontSize = 15
//
//        self.backgroundColor = .systemBackground
//
//        self.borderWidth = 0.5
//        self.borderColor = .systemGray2
//        self.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius
//        self.layer.cornerCurve = .continuous
        
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistencePriority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistencePriority), for: .vertical)
        applyDefaultSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyDefaultSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyDefaultSetup()
    }
    
    // MARK: - Override Functions

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
            }
        }
    }

    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.contentMode = .scaleToFill
        self.contentHorizontalAlignment = .left
        self.contentVerticalAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textAlignment = .natural
        self.clearsOnBeginEditing = true
        
        updateCornerRoundingIfNeeded()
    }

    private func updateCornerRoundingIfNeeded() {
        if self.hasAdjustedShouldRoundCorners == true {
            if shouldRoundCorners {
                self.layer.masksToBounds = true
                self.borderStyle = .roundedRect
            }
            
            self.layer.cornerRadius = shouldRoundCorners ? VisualConstant.LayerConstant.defaultCornerRadius : 0.0
            self.layer.cornerCurve = .continuous
        }
    }

}
