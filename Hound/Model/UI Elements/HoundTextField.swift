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
    
    var properties: JSONRequestBody = [:]
    
    // MARK: - Properties
    
    var staticCornerRadius: CGFloat? = Constant.Visual.Layer.defaultCornerRadius
    /// If true, self.layer.cornerRadius = Constant.Visual.Layer.defaultCornerRadius. Otherwise, self.layer.cornerRadius = 0.
    var shouldRoundCorners: Bool = false {
        didSet {
            updateCornerRounding()
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
    
    override var bounds: CGRect {
        didSet {
            updateCornerRounding()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.alpha = isEnabled ? 1 : 0.5
        }
    }
    
    /// Insets for all text/placeholder content.
    var textInsets: UIEdgeInsets = .zero {
        didSet { setNeedsDisplay(); invalidateIntrinsicContentSize() }
    }
    
    /// If true, standard insets are applied to text/placeholder; otherwise, no inset.
    var shouldInsetText: Bool = false {
        didSet {
            textInsets = shouldInsetText
            ? UIEdgeInsets(
                top: ConstraintConstant.Spacing.contentTightIntraVert,
                left: ConstraintConstant.Spacing.contentIntraHori,
                bottom: ConstraintConstant.Spacing.contentTightIntraVert,
                right: ConstraintConstant.Spacing.contentIntraHori)
            : .zero
        }
    }
    
    // MARK: - Main
    
    init(
        huggingPriority: Float = UILayoutPriority.defaultLow.rawValue,
        compressionResistancePriority: Float = UILayoutPriority.defaultLow.rawValue
    ) {
        super.init(frame: .zero)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .vertical)
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
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.contentMode = .scaleToFill
        self.contentHorizontalAlignment = .left
        self.contentVerticalAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textAlignment = .natural
        self.clearsOnBeginEditing = true
        self.font = Constant.Visual.Font.primaryRegularLabel
        
        HoundSizeDebugView.install(on: self)
        
        updateCornerRounding()
    }
    
}
