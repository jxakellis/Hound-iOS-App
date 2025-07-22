//
//  HoundTableHeaderFooterView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/20/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HoundTableHeaderFooterView: HoundHeaderFooterView {
    
    // MARK: - Views
    
    private let headerLabel: HoundLabel = {
        let label = HoundLabel()
        label.numberOfLines = 0
        label.font = Constant.Visual.Font.emphasizedSecondaryHeaderLabel
        return label
    }()
    
    // MARK: - Setup
    
    func setTitle(_ title: String) {
        headerLabel.text = title
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            // Use .high priority to avoid breaking during table view height estimation
            headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset).withPriority(.defaultHigh),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
    }
}
