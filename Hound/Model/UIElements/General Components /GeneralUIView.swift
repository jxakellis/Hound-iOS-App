//
//  GeneralUIView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/2/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralUIView: UIView, GeneralUIProtocol, GeneralUIKitProtocol {
    
    // MARK: - GeneralUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]
    
    // MARK: - GeneralUIProtocol
    
    private var didSetupGeneratedViews = false
    internal func setupGeneratedViews() {
        guard !didSetupGeneratedViews else {
            print("Attempting to re-invoke setupGeneratedViews for \(String(describing: type(of: self)))")
            return
        }
        didSetupGeneratedViews = true
        addSubViews()
        setupConstraints()
    }
    
    private var didAddSubViews = false
    internal func addSubViews() {
        guard !didAddSubViews else {
            print("Attempting to re-invoke setupGeneratedViews for \(String(describing: type(of: self)))")
            return
        }
        didAddSubViews = true
        return
    }
    
    private var didSetupConstraints = false
    internal func setupConstraints() {
        guard !didSetupConstraints else {
            print("Attempting to re-invoke setupGeneratedViews for \(String(describing: type(of: self)))")
            return
        }
        didSetupConstraints = true
        return
    }
    
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
    
    init(huggingPriority: Float = UILayoutPriority.defaultLow.rawValue, compressionResistancePriority: Float = UILayoutPriority.defaultLow.rawValue) {
        super.init(frame: .zero)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .vertical)
        self.applyDefaultSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyDefaultSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    // MARK: - Override Functions
    
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
    
    private func applyDefaultSetup() {
        self.contentMode = .scaleToFill
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setupGeneratedViews()
        
        SizeDebugView.install(on: self)
        
        updateCornerRoundingIfNeeded()
    }

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
