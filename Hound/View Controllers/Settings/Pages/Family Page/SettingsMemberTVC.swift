//
//  SettingsFamilyMemberTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyMemberTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = UIColor.systemBackground
        return view
    }()
    
    private let displayFullNameLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = VisualConstant.FontConstant.emphasizedSecondaryHeaderLabel
        return label
    }()
    
    private var chevronLeadingConstraint: GeneralLayoutConstraint!
    private var chevronTrailingConstraint: GeneralLayoutConstraint!
    private let chevronImageView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 300, compressionResistancePriority: 300)

        imageView.alpha = 0.75
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor.systemGray4
        
        return imageView
    }()
    
    private let iconView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 290, compressionResistancePriority: 290)

        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = UIColor.label
        
        return imageView
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsFamilyMemberTVC"
    
    // MARK: - Setup
    
    func setup(forDisplayFullName displayFullName: String) {
        displayFullNameLabel.text = displayFullName
        
        // if the user is not the family head, that means the cell should not be selectable nor should we show the chevron that indicates selectability
        isUserInteractionEnabled = UserInformation.isUserFamilyHead
        
        if UserInformation.isUserFamilyHead {
            chevronImageView.isHidden = false
            chevronLeadingConstraint.restore()
            chevronTrailingConstraint.restore()
        }
        else {
            chevronImageView.isHidden = true
            chevronLeadingConstraint.constant = 0.0
            chevronTrailingConstraint.constant = 0.0
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        contentView.backgroundColor = UIColor.secondarySystemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(chevronImageView)
        containerView.addSubview(displayFullNameLabel)
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        let iconSize: CGFloat = 30
        
        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        // iconView
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVertInset),
            iconView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset),
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor),
            iconView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
        
        // displayFullNameLabel
        NSLayoutConstraint.activate([
            displayFullNameLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            displayFullNameLabel.heightAnchor.constraint(equalTo: iconView.heightAnchor),
            displayFullNameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori)
        ])
        
        // chevronImageView
        chevronLeadingConstraint = GeneralLayoutConstraint(chevronImageView.leadingAnchor.constraint(equalTo: displayFullNameLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori))
        chevronTrailingConstraint = GeneralLayoutConstraint(containerView.trailingAnchor.constraint(equalTo: chevronImageView.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori))
        NSLayoutConstraint.activate([
            chevronLeadingConstraint.constraint,
            chevronTrailingConstraint.constraint,
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.createAspectRatio(ConstraintConstant.Button.chevronAspectRatio),
            chevronImageView.createHeightMultiplier(ConstraintConstant.Button.chevronHeightMultiplier, relativeToWidthOf: contentView),
            chevronImageView.createMaxHeight(ConstraintConstant.Button.chevronMaxHeight)
        ])
    }

}
