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
        label.font = Constant.Visual.Font.primaryHeaderLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    
    let backButton: HoundButton = {
        let button = HoundButton(huggingPriority: 490, compressionResistancePriority: 490)
        
        button.tintColor = UIColor.label
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.backgroundCircleTintColor = UIColor.systemBackground
        
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
        label.font = Constant.Visual.Font.tertiaryHeaderLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
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
        if useLeftTextAlignment {
            pageHeaderCenterXConstraint.isActive = false
            pageHeaderLeadingConstraint.isActive = true
        }
        else {
            pageHeaderLeadingConstraint.isActive = false
            pageHeaderCenterXConstraint.isActive = true
        }
    }
    
    private func handleIsDescriptionEnabled() {
        if isDescriptionEnabled {
            pageDescriptionLabel.isHidden = false
            pageHeaderBottomConstraint.isActive = false
            pageDescriptionTopConstraint.isActive = true
            pageDescriptionBottomConstraint.isActive = true
        }
        else {
            pageDescriptionTopConstraint.isActive = false
            pageDescriptionBottomConstraint.isActive = false
            pageDescriptionLabel.isHidden = true
            pageHeaderBottomConstraint.isActive = true
        }
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
        pageHeaderLeadingConstraint = GeneralLayoutConstraint(pageHeaderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset))
        pageHeaderCenterXConstraint = GeneralLayoutConstraint(pageHeaderLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor))
        
        handleUseLeftTextAlignment()
        
        NSLayoutConstraint.activate([
            pageHeaderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset)
        ])
        
        // backButton
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: self.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            backButton.leadingAnchor.constraint(equalTo: pageHeaderLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentTightIntraHori),
            backButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteCircleHoriInset),
            backButton.createHeightMultiplier(Constant.Constraint.Button.miniCircleHeightMultiplier, relativeToWidthOf: self),
            backButton.createMaxHeight(Constant.Constraint.Button.miniCircleMaxHeight),
            backButton.createSquareAspectRatio()
        ])
        
        // pageDescriptionLabel
        pageHeaderBottomConstraint = GeneralLayoutConstraint(pageHeaderLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor))
        pageDescriptionTopConstraint = GeneralLayoutConstraint(pageDescriptionLabel.topAnchor.constraint(equalTo: pageHeaderLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentTallIntraVert))
        pageDescriptionBottomConstraint = GeneralLayoutConstraint(pageDescriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor))
        
        handleIsDescriptionEnabled()
        
        NSLayoutConstraint.activate([
            pageDescriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            pageDescriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            pageDescriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }

}
