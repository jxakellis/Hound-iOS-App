//
//  GeneralHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/20/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralHeaderView: GeneralUIHeaderFooterView {
    
    // MARK: - Views
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
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
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Spacing.contentAbsVertInset),
            headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Spacing.contentAbsVertInset),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)
        ])
    }
}

