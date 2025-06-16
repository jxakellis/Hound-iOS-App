//
//  SettingsFamilyMemberTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyMemberTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let displayFullNameLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = .systemFont(ofSize: 17.5, weight: .medium)
        return label
    }()
    
    private let chevronLeadingConstraintConstant = 5.0
    private weak var chevronLeadingConstraint: NSLayoutConstraint!
    private let chevronTrailingConstraintConstant = 7.5
    private weak var chevronTrailingConstraint: NSLayoutConstraint!
    private let chevonImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 285, compressionResistancePriority: 285)
        
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray4
        
        return imageView
    }()
    
    private let iconView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 290, compressionResistancePriority: 290)

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
        chevonImageView.isHidden = !UserInformation.isUserFamilyHead
        
        chevronLeadingConstraint.constant = UserInformation.isUserFamilyHead ? chevronLeadingConstraintConstant : 0.0
        chevronTrailingConstraint.constant = UserInformation.isUserFamilyHead ? chevronTrailingConstraintConstant : 0.0
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
        
        // iconView
        let iconTop = iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10)
        let iconBottom = iconView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        let iconLeading = iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20)
        let iconWidth = iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor)
        let iconHeight = iconView.heightAnchor.constraint(equalToConstant: 30)
        
        // displayFullNameLabel
        let labelTop = displayFullNameLabel.topAnchor.constraint(equalTo: iconView.topAnchor)
        let labelLeading = displayFullNameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 5)
        let labelBottom = displayFullNameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        
        // chevonImageView (chevron)
        chevronLeadingConstraint = chevonImageView.leadingAnchor.constraint(equalTo: displayFullNameLabel.trailingAnchor, constant: chevronLeadingConstraintConstant)
        chevronTrailingConstraint = containerView.trailingAnchor.constraint(equalTo: chevonImageView.trailingAnchor, constant: chevronTrailingConstraintConstant)
        let chevronCenterY = chevonImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        let chevronWidthRatio = chevonImageView.widthAnchor.constraint(equalTo: chevonImageView.heightAnchor, multiplier: 1 / 1.5)
        let chevronWidthToIcon = chevonImageView.widthAnchor.constraint(equalTo: iconView.heightAnchor, multiplier: 20 / 35)
        
        // containerView
        let containerTop = containerView.topAnchor.constraint(equalTo: contentView.topAnchor)
        let containerBottom = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        let containerLeading = containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        let containerTrailing = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        
        NSLayoutConstraint.activate([
            iconTop, iconBottom, iconLeading, iconWidth, iconHeight,
            labelTop, labelLeading, labelBottom,
            chevronLeadingConstraint, chevronTrailingConstraint, chevronCenterY, chevronWidthRatio, chevronWidthToIcon,
            containerTop, containerBottom, containerLeading, containerTrailing
        ])
    }

}
