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
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(230), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(230), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(730), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(730), for: .vertical)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Additional UI Elements
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(751), for: .vertical)
        label.text = "Account"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let alwaysOnSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.contentMode = .scaleToFill
        uiSwitch.setContentHuggingPriority(UILayoutPriority(255), for: .horizontal)
        uiSwitch.setContentHuggingPriority(UILayoutPriority(255), for: .vertical)
        uiSwitch.setContentCompressionResistancePriority(UILayoutPriority(755), for: .horizontal)
        uiSwitch.setContentCompressionResistancePriority(UILayoutPriority(755), for: .vertical)
        uiSwitch.isEnabled = false
        uiSwitch.contentHorizontalAlignment = .center
        uiSwitch.contentVerticalAlignment = .center
        uiSwitch.isOn = true
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.onTintColor = .systemBlue
        return uiSwitch
    }()
    
    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
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
        contentView.addSubview(headerLabel)
        contentView.addSubview(alwaysOnSwitch)
        contentView.addSubview(descriptionLabel)
        
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            alwaysOnSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            alwaysOnSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10),
            alwaysOnSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.centerYAnchor.constraint(equalTo: alwaysOnSwitch.centerYAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: alwaysOnSwitch.bottomAnchor, constant: 7.5),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
        ])
        
    }
}
