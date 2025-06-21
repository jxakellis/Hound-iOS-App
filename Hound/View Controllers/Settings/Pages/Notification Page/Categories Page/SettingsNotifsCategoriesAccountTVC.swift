//
//  SettingsNotifsCategoriesAccountTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsCategoriesAccountTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 230, compressionResistancePriority: 230)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Additional UI Elements
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Account"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let alwaysOnSwitch: GeneralUISwitch = {
        let uiSwitch = GeneralUISwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.isEnabled = false
        uiSwitch.isOn = true
        return uiSwitch
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsCategoriesAccountTVC"
    
    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    // MARK: - Setup
    
    private func setup() {
        let precalculatedDynamicTextColor = descriptionLabel.textColor
        descriptionLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            let message = NSMutableAttributedString(
                string: "Receive notifications about your account. ",
                attributes: [
                    .font: VisualConstant.FontConstant.secondaryLabelColorFeatureDescriptionLabel,
                    .foregroundColor: precalculatedDynamicTextColor as Any
                ]
            )
            
            message.append(NSAttributedString(
                string: "This category cannot be turned off.",
                attributes: [
                    .font: VisualConstant.FontConstant.emphasizedSecondaryLabelColorFeatureDescriptionLabel,
                    .foregroundColor: precalculatedDynamicTextColor as Any
                ])
            )
            
            message.append(NSAttributedString(
                string: " Examples include: getting kicked from your Hound family, accidentally terminating Hound while Loud Alarms is enabled.",
                attributes: [
                    .font: VisualConstant.FontConstant.secondaryLabelColorFeatureDescriptionLabel,
                    .foregroundColor: precalculatedDynamicTextColor as Any
                ])
            )
            
            return message
        }
    }
    
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

        // alwaysOnSwitch
        let alwaysOnSwitchTop = alwaysOnSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Global.contentInset)
        let alwaysOnSwitchLeading = alwaysOnSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10)
        let alwaysOnSwitchTrailing = alwaysOnSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40)
        
        // headerLabel
        let headerLabelLeading = headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentInset)
        let headerLabelCenterY = headerLabel.centerYAnchor.constraint(equalTo: alwaysOnSwitch.centerYAnchor)
        
        // descriptionLabel
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: alwaysOnSwitch.bottomAnchor, constant: 7.5)
        let descriptionLabelBottom = descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Global.contentInset)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentInset)
        let descriptionLabelTrailing = descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Global.contentInset)
        
        NSLayoutConstraint.activate([
            // alwaysOnSwitch
            alwaysOnSwitchTop, alwaysOnSwitchLeading, alwaysOnSwitchTrailing,
            
            // headerLabel
            headerLabelLeading, headerLabelCenterY,
            
            // descriptionLabel
            descriptionLabelTop, descriptionLabelBottom, descriptionLabelLeading, descriptionLabelTrailing
        ])
    }

}
