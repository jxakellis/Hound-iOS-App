//
//  SettingsNotifsCategoriesTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsCategoriesTVC: GeneralUITableViewCell {
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "Notification Categories"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.text = "By default, Hound will send notifications about your account, family, logs, and reminders."
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let chevonImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 300, compressionResistancePriority: 300)

        imageView.alpha = 0.75
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray4
        
        return imageView
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsCategoriesTVC"
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(chevonImageView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // headerLabel
        let headerLabelTop = headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Global.contentHoriInset)
        let headerLabelLeading = headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset)
        let headerLabelHeight = headerLabel.heightAnchor.constraint(equalToConstant: 25)
        let headerLabelTrailing = headerLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor)
        
        // chevonImageView
        let chevonImageViewLeading = chevonImageView.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 5)
        let chevonImageViewTrailing = chevonImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset)
        let chevonImageViewCenterY = chevonImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        let chevonImageViewWidthByHeight = chevonImageView.widthAnchor.constraint(equalTo: chevonImageView.heightAnchor, multiplier: 1.0 / 1.5)
        let chevonImageViewWidthByHeader = chevonImageView.widthAnchor.constraint(equalTo: headerLabel.heightAnchor, multiplier: 20.0 / 25.0)
        chevonImageViewWidthByHeader.priority = .defaultHigh // Prevents conflict in rare cases
        
        // descriptionLabel
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 7.5)
        let descriptionLabelBottom = descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Global.contentHoriInset)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor)
        // trailing is already linked via headerLabel.trailing
        
        NSLayoutConstraint.activate([
            // headerLabel
            headerLabelTop, headerLabelLeading, headerLabelHeight, headerLabelTrailing,
            
            // chevonImageView
            chevonImageViewLeading, chevonImageViewTrailing, chevonImageViewCenterY, chevonImageViewWidthByHeight, chevonImageViewWidthByHeader,
            
            // descriptionLabel
            descriptionLabelTop, descriptionLabelBottom, descriptionLabelLeading
        ])
    }

}
