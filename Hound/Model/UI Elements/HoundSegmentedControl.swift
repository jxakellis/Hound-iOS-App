//
//  HoundSegmentedControl.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HoundSegmentedControl: UISegmentedControl, HoundUIProtocol, HoundUIKitProtocol {
    
    // MARK: - HoundUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]
    
    // MARK: - HoundUIProtocol
    
    private var didSetupGeneratedViews = false
    internal func setupGeneratedViews() {
        guard !didSetupGeneratedViews else {
            HoundLogger.general.warning("Attempting to re-invoke setupGeneratedViews for \(String(describing: type(of: self)))")
            return
        }
        didSetupGeneratedViews = true
        addSubViews()
        setupConstraints()
    }
    
    private var didAddSubViews = false
    internal func addSubViews() {
        guard !didAddSubViews else {
            HoundLogger.general.warning("Attempting to re-invoke setupGeneratedViews for \(String(describing: type(of: self)))")
            return
        }
        didAddSubViews = true
        return
    }
    
    private var didSetupConstraints = false
    internal func setupConstraints() {
        guard !didSetupConstraints else {
            HoundLogger.general.warning("Attempting to re-invoke setupGeneratedViews for \(String(describing: type(of: self)))")
            return
        }
        didSetupConstraints = true
        return
    }

    // MARK: - Override Properties

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

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkForOversizedFrame()
    }

    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.contentMode = .scaleToFill
        self.contentHorizontalAlignment = .left
        self.contentVerticalAlignment = .top
        self.apportionsSegmentWidthsByContent = true
        self.translatesAutoresizingMaskIntoConstraints = false
        
        HoundSizeDebugView.install(on: self)
        
        setupGeneratedViews()
    }
}
