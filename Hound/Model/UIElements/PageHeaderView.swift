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
    
    private var pageHeaderLeadingConstraint: GeneralLayoutConstraint!
    private var pageHeaderCenterXConstraint: GeneralLayoutConstraint!
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
    
    private var pageHeaderBottomConstraint: GeneralLayoutConstraint!
    private var pageDescriptionTopConstraint: GeneralLayoutConstraint!
    private var pageDescriptionBottomConstraint: GeneralLayoutConstraint!
    let pageDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 480, compressionResistancePriority: 480)
        label.text = "Default Page Description"
        label.font = VisualConstant.FontConstant.tertiaryHeaderLabel
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Properties
    
    var useLeftTextAlignment: Bool = true {
        didSet {
            handleUseLeftTextAlignment()
        }
    }
    
    var isDescriptionEnabled: Bool = false {
        didSet {
            handleIsDescriptionEnabled()
        }
    }
    
    // MARK: - Functions
    
    private func handleUseLeftTextAlignment() {
        pageHeaderLabel.textAlignment = useLeftTextAlignment ? .left : .center
        pageDescriptionLabel.textAlignment = .center
        pageHeaderLeadingConstraint.isActive = useLeftTextAlignment
        pageHeaderCenterXConstraint.isActive = !useLeftTextAlignment
    }
    
    private func handleIsDescriptionEnabled() {
        pageDescriptionLabel.isHidden = !isDescriptionEnabled
        pageHeaderBottomConstraint.isActive = !isDescriptionEnabled
        pageDescriptionTopConstraint.isActive = isDescriptionEnabled
        pageDescriptionBottomConstraint.isActive = isDescriptionEnabled
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        self.addSubview(backButton)
        self.addSubview(pageHeaderLabel)
        self.addSubview(pageDescriptionLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // pageHeaderLabel
        pageHeaderLeadingConstraint = GeneralLayoutConstraint(pageHeaderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset))
        pageHeaderCenterXConstraint = GeneralLayoutConstraint(pageHeaderLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor))
        
        handleUseLeftTextAlignment()
        
        NSLayoutConstraint.activate([
            pageHeaderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: ConstraintConstant.Spacing.contentAbsVertInset),
            pageHeaderLabel.createHeightMultiplier(ConstraintConstant.Text.headerLabelHeightMultipler, relativeToWidthOf: self),
            pageHeaderLabel.createMaxHeight(ConstraintConstant.Text.headerLabelMaxHeight)
        ])
        
        // backButton
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: self.topAnchor, constant: ConstraintConstant.Spacing.miniCircleAbsInset),
            backButton.leadingAnchor.constraint(equalTo: pageHeaderLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHoriSpacing),
            backButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -ConstraintConstant.Spacing.miniCircleAbsInset),
            backButton.createHeightMultiplier(ConstraintConstant.Button.miniCircleHeightMultiplier, relativeToWidthOf: self),
            backButton.createMaxHeight(ConstraintConstant.Button.miniCircleMaxHeight),
            backButton.createSquareAspectRatio()
        ])
        
        // pageDescriptionLabel
        pageHeaderBottomConstraint = GeneralLayoutConstraint(pageHeaderLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor))
        pageDescriptionTopConstraint = GeneralLayoutConstraint(pageDescriptionLabel.topAnchor.constraint(equalTo: pageHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.headerVertSpacingToSection))
        pageDescriptionBottomConstraint = GeneralLayoutConstraint(pageDescriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor))
        
        handleIsDescriptionEnabled()
        
        NSLayoutConstraint.activate([
            pageDescriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            pageDescriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            pageDescriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }

}
