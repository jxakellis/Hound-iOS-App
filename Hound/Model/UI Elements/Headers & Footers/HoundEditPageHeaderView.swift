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
        label.font = Constant.VisualFont.primaryHeaderLabel
        label.textColor = UIColor.systemBlue
        label.numberOfLines = 0
        return label
    }()

    let leadingButton: HoundButton = {
        let button = HoundButton(huggingPriority: 490, compressionResistancePriority: 490)
        button.tintColor = UIColor.systemBlue
        button.isHidden = true
        return button
    }()

    let trailingButton: HoundButton = {
        let button = HoundButton(huggingPriority: 490, compressionResistancePriority: 490)
        button.tintColor = UIColor.systemBlue
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
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            titleLabel.centerYAnchor.constraint(greaterThanOrEqualTo: leadingButton.centerYAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        // leadingButton
        NSLayoutConstraint.activate([
            leadingButton.topAnchor.constraint(equalTo: topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            leadingButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constant.Constraint.Spacing.absoluteCircleHoriInset),
            leadingButton.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -Constant.Constraint.Spacing.contentIntraHori),
            leadingButton.createHeightMultiplier(Constant.Constraint.Button.miniCircleHeightMultiplier, relativeToWidthOf: self),
            leadingButton.createMaxHeight(Constant.Constraint.Button.miniCircleMaxHeight),
            leadingButton.createSquareAspectRatio()
        ])

        // trailingButton
        NSLayoutConstraint.activate([
            trailingButton.topAnchor.constraint(equalTo: topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            trailingButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteCircleHoriInset),
            trailingButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            trailingButton.createHeightMultiplier(Constant.Constraint.Button.miniCircleHeightMultiplier, relativeToWidthOf: self),
            trailingButton.createMaxHeight(Constant.Constraint.Button.miniCircleMaxHeight),
            trailingButton.createSquareAspectRatio()
        ])
    }

    // MARK: - Functions

    /// Sets the header title text.
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
