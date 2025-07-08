//
//  HoundEditPageHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class HoundEditPageHeaderView: HoundView {

    // MARK: - Elements

    private let titleLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 500, compressionResistancePriority: 500)
        label.textAlignment = .center
        label.text = "Default Edit Page Header"
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        label.textColor = .systemBlue
        label.numberOfLines = 0
        return label
    }()

    let leadingButton: HoundButton = {
        let button = HoundButton(huggingPriority: 490, compressionResistancePriority: 490)
        button.tintColor = .systemBlue
        button.backgroundCircleTintColor = .systemBackground
        button.isHidden = true
        return button
    }()

    let trailingButton: HoundButton = {
        let button = HoundButton(huggingPriority: 490, compressionResistancePriority: 490)
        button.tintColor = .systemBlue
        button.backgroundCircleTintColor = .systemBackground
        button.isHidden = true
        return button
    }()

    // MARK: - Properties

    /// Controls if the leading button should be visible.
    var isLeadingButtonEnabled: Bool {
        get { !leadingButton.isHidden }
        set { leadingButton.isHidden = !newValue }
    }

    /// Controls if the trailing button should be visible.
    var isTrailingButtonEnabled: Bool {
        get { !trailingButton.isHidden }
        set { trailingButton.isHidden = !newValue }
    }

    // MARK: - Setup Elements

    override func addSubViews() {
        super.addSubViews()
        addSubview(titleLabel)
        addSubview(leadingButton)
        addSubview(trailingButton)
    }

    override func setupConstraints() {
        super.setupConstraints()
        
        // titleLabel
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: ConstraintConstant.Spacing.absoluteVertInset),
            titleLabel.centerYAnchor.constraint(greaterThanOrEqualTo: leadingButton.centerYAnchor, constant: ConstraintConstant.Spacing.absoluteVertInset),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        // leadingButton
        NSLayoutConstraint.activate([
            leadingButton.topAnchor.constraint(equalTo: topAnchor, constant: ConstraintConstant.Spacing.absoluteVertInset),
            leadingButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteCircleHoriInset),
            leadingButton.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            leadingButton.createHeightMultiplier(ConstraintConstant.Button.miniCircleHeightMultiplier, relativeToWidthOf: self),
            leadingButton.createMaxHeight(ConstraintConstant.Button.miniCircleMaxHeight),
            leadingButton.createSquareAspectRatio()
        ])

        // trailingButton
        NSLayoutConstraint.activate([
            trailingButton.topAnchor.constraint(equalTo: topAnchor, constant: ConstraintConstant.Spacing.absoluteVertInset),
            trailingButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteCircleHoriInset),
            trailingButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            trailingButton.createHeightMultiplier(ConstraintConstant.Button.miniCircleHeightMultiplier, relativeToWidthOf: self),
            trailingButton.createMaxHeight(ConstraintConstant.Button.miniCircleMaxHeight),
            trailingButton.createSquareAspectRatio()
        ])
    }

    // MARK: - Functions

    /// Sets the header title text.
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
