//
//  HoundPawButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/4/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class HoundPawImageView: HoundImageView {

    // MARK: - Main

    override init(huggingPriority: Float = UILayoutPriority.defaultLow.rawValue, compressionResistancePriority: Float = UILayoutPriority.defaultLow.rawValue) {
        super.init(huggingPriority: huggingPriority, compressionResistancePriority: compressionResistancePriority)
        updatePawImage()
    }

    override init() {
        super.init()
        updatePawImage()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        updatePawImage()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }

    // MARK: - Override Functions

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updatePawImage()
        }
    }

    // MARK: - Functions

    private func updatePawImage() {
        self.image = UITraitCollection.current.userInterfaceStyle == .dark
        ? UIImage.init(named: "blackPawWithHands") ?? UIImage()
        : UIImage.init(named: "whitePawWithHands") ?? UIImage()
    }
}
