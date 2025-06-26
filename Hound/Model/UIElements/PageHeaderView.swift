//
//  PageSheetHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/25/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class PageSheetHeaderView: GeneralUIView {
    
    // MARK: - Elements
    
    let pageHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 500, compressionResistancePriority: 500)
        label.text = "Default Page Header"
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        return label
    }()
    
    let backButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 490, compressionResistancePriority: 490)
        
        button.tintColor = .label
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        
        button.shouldRoundCorners = true
        button.shouldDismissParentViewController = true
        return button
    }()
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        self.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        self.addSubview(backButton)
        self.addSubview(pageHeaderLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // pageHeaderLabel
        NSLayoutConstraint.activate([
            pageHeaderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: ConstraintConstant.Global.contentVertInset),
            pageHeaderLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            pageHeaderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset),
            pageHeaderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset),
            pageHeaderLabel.createMaxHeightConstraint( ConstraintConstant.Text.headerLabelMaxHeight),
            pageHeaderLabel.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: ConstraintConstant.Text.headerLabelHeightMultipler ).withPriority(.defaultHigh)
        ])
        
        // backButton
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: self.topAnchor, constant: ConstraintConstant.Button.miniCircleInset),
            backButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -ConstraintConstant.Button.miniCircleInset),
            backButton.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: ConstraintConstant.Button.miniCircleHeightMultiplier).withPriority(.defaultHigh),
            backButton.createMaxHeightConstraint( ConstraintConstant.Button.miniCircleMaxHeight),
            backButton.createSquareConstraint()
        ])
        
    }

}
