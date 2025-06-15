//
//  GeneralUISwitch.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/13/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class GeneralUISwitch: UISwitch, GeneralUIProtocol {
    
    // MARK: - GeneralUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]

    // MARK: - Main
    
    init(huggingPriority: Float = 250, compressionResistancePriority: Float = 250) {
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
    
    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.contentMode = .scaleToFill
        self.contentHorizontalAlignment = .center
        self.contentVerticalAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
        self.onTintColor = .systemBlue
    }

}
