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
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let displayFullNameLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = VisualConstant.FontConstant.emphasizedSecondaryHeaderLabel
        return label
    }()
    
    private var chevronLeadingConstraint: GeneralLayoutConstraint!
    private var chevronTrailingConstraint: GeneralLayoutConstraint!
    private let chevonImageView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 285, compressionResistancePriority: 285)
        
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray4
        
        return imageView
    }()
    
    private let iconView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 290, compressionResistancePriority: 290)

        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .label
        
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
            chevonImageView.isHidden = false
            chevronLeadingConstraint.restore()
            chevronTrailingConstraint.restore()
        }
        else {
            chevonImageView.isHidden = true
            chevronLeadingConstraint.constant = 0.0
            chevronTrailingConstraint.constant = 0.0
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        contentView.backgroundColor = .secondarySystemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(chevonImageView)
        containerView.addSubview(displayFullNameLabel)
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        let chevronInset: CGFloat = 7.5
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
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVerticalInset),
            iconView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVerticalInset),
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
        
        // chevonImageView
        chevronLeadingConstraint = GeneralLayoutConstraint(chevonImageView.leadingAnchor.constraint(equalTo: displayFullNameLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori))
        chevronTrailingConstraint = GeneralLayoutConstraint(containerView.trailingAnchor.constraint(equalTo: chevonImageView.trailingAnchor, constant: chevronInset))
        NSLayoutConstraint.activate([
            chevronLeadingConstraint.constraint,
            chevronTrailingConstraint.constraint,
            chevonImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevonImageView.widthAnchor.constraint(equalTo: chevonImageView.heightAnchor, multiplier: ConstraintConstant.Button.chevronAspectRatio),
            chevonImageView.widthAnchor.constraint(equalTo: iconView.heightAnchor, multiplier: 20 / 35)
        ])
    }

}
