//
//  GeneralUIScrollView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralUIScrollView: UIScrollView, GeneralUIProtocol, GeneralUIKitProtocol {
    
    // MARK: - GeneralUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]
    
    // MARK: - GeneralUIProtocol
    
    internal func setupGeneratedViews() {
        addSubViews()
        setupConstraints()
    }
    
    internal func addSubViews() {
        return
    }
    
    internal func setupConstraints() {
        return
    }

    // MARK: - Override Properties

    // MARK: - Main
    
    init(huggingPriority: Float = 250, compressionResistancePriority: Float = 750) {
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
        applyDefaultSetup()
    }

    // MARK: - Functions
    
    private func applyDefaultSetup() {
        setupGeneratedViews()
        
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = true
        self.contentMode = .scaleToFill
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
