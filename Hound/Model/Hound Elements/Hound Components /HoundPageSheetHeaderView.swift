//
//  HoundPageSheetHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/25/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class HoundPageSheetHeaderView: HoundView {
    
    // MARK: - Elements
    
    private var pageHeaderLeadingConstraint: GeneralLayoutConstraint!
    private var pageHeaderCenterXConstraint: GeneralLayoutConstraint!
    let pageHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 500, compressionResistancePriority: 500)
        label.text = "Default Page Header"
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        label.numberOfLines = 0
        return label
    }()
    
    let backButton: HoundButton = {
        let button = HoundButton(huggingPriority: 490, compressionResistancePriority: 490)
        
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
    let pageDescriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 480, compressionResistancePriority: 480)
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
        pageHeaderLeadingConstraint = GeneralLayoutConstraint(pageHeaderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset))
        pageHeaderCenterXConstraint = GeneralLayoutConstraint(pageHeaderLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor))
        
        handleUseLeftTextAlignment()
        
        NSLayoutConstraint.activate([
            pageHeaderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: ConstraintConstant.Spacing.absoluteVerticalInset)
        ])
        
        // backButton
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: self.topAnchor, constant: ConstraintConstant.Spacing.absoluteMiniCircleInset),
            backButton.leadingAnchor.constraint(equalTo: pageHeaderLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            backButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteMiniCircleInset),
            backButton.createHeightMultiplier(ConstraintConstant.Button.miniCircleHeightMultiplier, relativeToWidthOf: self),
            backButton.createMaxHeight(ConstraintConstant.Button.miniCircleMaxHeight),
            backButton.createSquareAspectRatio()
        ])
        
        // pageDescriptionLabel
        pageHeaderBottomConstraint = GeneralLayoutConstraint(pageHeaderLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor))
        pageDescriptionTopConstraint = GeneralLayoutConstraint(pageDescriptionLabel.topAnchor.constraint(equalTo: pageHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert))
        pageDescriptionBottomConstraint = GeneralLayoutConstraint(pageDescriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor))
        
        handleIsDescriptionEnabled()
        
        NSLayoutConstraint.activate([
            pageDescriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            pageDescriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            pageDescriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }

}
