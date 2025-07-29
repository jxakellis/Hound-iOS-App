//
//  SettingsNotifsCategoriesFamilyTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsCategoriesFamilyTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    private let headerLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Family"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private let alwaysOnSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.isEnabled = false
        uiSwitch.isOn = true
        return uiSwitch
    }()
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 230, compressionResistancePriority: 230)
        label.numberOfLines = 0
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
        
        label.attributedText = {
            let message = NSMutableAttributedString(
                string: "Receive notifications about your Hound family. ",
                attributes: [.font: Constant.Visual.Font.secondaryColorDescLabel]
            )
            
            message.append(NSAttributedString(
                string: "This category cannot be turned off.",
                attributes: [.font: Constant.Visual.Font.emphasizedSecondaryColorDescLabel])
            )
            
            message.append(NSAttributedString(
                string: " Examples include: a user joining, leaving, or locking your family.",
                attributes: [.font: Constant.Visual.Font.secondaryColorDescLabel])
            )
            
            return message
        }()
        
        return label
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsCategoriesFamilyTVC"
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(alwaysOnSwitch)
        contentView.addSubview(descriptionLabel)
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
        
        // alwaysOnSwitch
        NSLayoutConstraint.activate([
            alwaysOnSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            alwaysOnSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            alwaysOnSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        ])
        
        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset)
        ])
    }
    
}
