//
//  SettingsNotifsCategoriesFamilyTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO VERIFY UI
final class SettingsNotifsCategoriesFamilyTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Family"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private let alwaysOnSwitch: GeneralUISwitch = {
        let uiSwitch = GeneralUISwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.isEnabled = false
        uiSwitch.isOn = true
        return uiSwitch
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 230, compressionResistancePriority: 230)
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        
        let precalculatedDynamicTextColor = label.textColor
        label.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            let message = NSMutableAttributedString(
                string: "Receive notifications about your Hound family. ",
                attributes: [
                    .font: VisualConstant.FontConstant.secondaryColorDescLabel,
                    .foregroundColor: precalculatedDynamicTextColor as Any
                ]
            )
            
            message.append(NSAttributedString(
                string: "This category cannot be turned off.",
                attributes: [
                    .font: VisualConstant.FontConstant.emphasizedSecondaryColorDescLabel,
                    .foregroundColor: precalculatedDynamicTextColor as Any
                ])
            )
            
            message.append(NSAttributedString(
                string: " Examples include: a user joining, leaving, or locking your family.",
                attributes: [
                    .font: VisualConstant.FontConstant.secondaryColorDescLabel,
                    .foregroundColor: precalculatedDynamicTextColor as Any
                ])
            )
            
            return message
        }
        
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
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Spacing.contentAbsVertInset),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            headerLabel.createMaxHeight( ConstraintConstant.Text.sectionLabelMaxHeight),
            headerLabel.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: ConstraintConstant.Text.sectionLabelHeightMultipler ).withPriority(.defaultHigh)
        ])

        // alwaysOnSwitch
        NSLayoutConstraint.activate([
            alwaysOnSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            alwaysOnSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHoriSpacing),
            alwaysOnSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset * 2.0)
        ])

        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVertSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Spacing.contentAbsVertInset)
        ])
    }

}
