//
//  SettingsNotifsAlarmsTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsAlarmsTVC: HoundTableViewCell {
    private let headerLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "Configure Alarms"
        label.font = Constant.VisualFont.secondaryHeaderLabel
        return label
    }()
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.text = "By default, your reminder alarms will repeatedly ring, play the 'Radar' sound effect, and snooze for five minutes"
        label.numberOfLines = 0
        label.font = Constant.VisualFont.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    private let chevronImageView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 300, compressionResistancePriority: 300)
        
        imageView.alpha = 0.75
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor.systemGray4
        
        return imageView
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsAlarmsTVC"
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(chevronImageView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            headerLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            headerLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: contentView)
        ])
        
        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor)
        ])

        // chevronImageView
        NSLayoutConstraint.activate([
            chevronImageView.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.createAspectRatio(Constant.Constraint.Button.chevronAspectRatio),
            chevronImageView.createHeightMultiplier(Constant.Constraint.Button.chevronHeightMultiplier, relativeToWidthOf: contentView),
            chevronImageView.createMaxHeight(Constant.Constraint.Button.chevronMaxHeight)
        ])
        
    }

}
