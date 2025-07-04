//
//  GeneralHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/20/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralHeaderView: HoundHeaderFooterView {
    
    // MARK: - Views
    
    private let headerLabel: HoundLabel = {
        let label = HoundLabel()
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.emphasizedSecondaryHeaderLabel
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
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVerticalInset),
            // when table view is calculating the height of this view, it might assign a UIView-Encapsulated-Layout-Height which is invalid (too big or too small) for pageSheetHeaderView. This would cause a unresolvable constraints error, causing one of them to break. However, since this is temporary when it calculates the height, we can avoid this .defaultHigh constraint that temporarily turns off
            headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVerticalInset).withPriority(.defaultHigh),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
    }
}
