//
//  HoundStackView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/2/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HoundStackView: UIStackView, HoundUIProtocol, HoundDynamicCorners {
    
    // MARK: - HoundUIProtocol
    
    var properties: JSONRequestBody = [:]
    
    // MARK: - Properties
    
    var staticCornerRadius: CGFloat? = Constant.Visual.Layer.defaultCornerRadius
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
    
    // MARK: - Override Properties
    
    override var bounds: CGRect {
        didSet {
            updateCornerRounding()
        }
    }
    
    // MARK: - Main
    
    init(huggingPriority: Float = UILayoutPriority.defaultLow.rawValue, compressionResistancePriority: Float = UILayoutPriority.defaultLow.rawValue) {
        super.init(frame: .zero)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .vertical)
        self.applyDefaultSetup()
    }
    
    init() {
        super.init(frame: .zero)
        let priority = UILayoutPriority.defaultLow.rawValue
        self.setContentHuggingPriority(UILayoutPriority(priority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(priority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(priority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(priority), for: .vertical)
        self.applyDefaultSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyDefaultSetup()
    }
    
    init(arrangedSubviews: [UIView]) {
        super.init(frame: .zero)
        arrangedSubviews.forEach { view in
            self.addArrangedSubview(view)
        }
        let priority = UILayoutPriority.defaultLow.rawValue
        self.setContentHuggingPriority(UILayoutPriority(priority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(priority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(priority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(priority), for: .vertical)
        applyDefaultSetup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkForOversizedFrame()
    }
    
    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.alignment = .fill
        self.distribution = .fill
        self.translatesAutoresizingMaskIntoConstraints = false
        
        HoundSizeDebugView.install(on: self)
        
        updateCornerRounding()
    }
    
    static func inputFieldStack(_ header: UIView) -> HoundStackView {
        let stack = HoundStackView()
        stack.addArrangedSubview(header)
        stack.axis = .vertical
        stack.spacing = Constant.Constraint.Spacing.contentTightIntraVert
        return stack
    }
}
