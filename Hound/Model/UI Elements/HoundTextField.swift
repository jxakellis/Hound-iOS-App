//
//  HoundTextField.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/30/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class HoundTextField: UITextField, HoundUIProtocol, HoundDynamicBorder, HoundDynamicCorners {
    
    // MARK: - HoundUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]

    // MARK: - Properties
    var staticCornerRadius: CGFloat? = nil
    /// If true, self.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius. Otherwise, self.layer.cornerRadius = 0.
    var shouldRoundCorners: Bool = false {
        didSet {
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
        huggingPriority: Float = UILayoutPriority.defaultLow.rawValue,
        compressionResistencePriority: Float = UILayoutPriority.defaultLow.rawValue
    ) {
        super.init(frame: .zero)
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
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkForOversizedFrame()
    }
    
    // MARK: - Override Functions

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateDynamicBorderColor(using: previousTraitCollection)
    }

    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.contentMode = .scaleToFill
        self.contentHorizontalAlignment = .left
        self.contentVerticalAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textAlignment = .natural
        self.clearsOnBeginEditing = true
        
        self.minimumFontSize = 15
        self.font = VisualConstant.FontConstant.primaryRegularLabel
        
        HoundSizeDebugView.install(on: self)
        
        updateCornerRoundingIfNeeded()
    }

}
