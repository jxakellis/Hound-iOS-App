//
//  SettingsNotifsAlarmsLoudNotificationsTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO VERIFY UI
final class SettingsNotifsAlarmsLoudNotificationsTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Loud Alarms"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private lazy var isLoudNotificationEnabledSwitch: GeneralUISwitch = {
        let uiSwitch = GeneralUISwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.isOn = UserConfiguration.isNotificationEnabled
        uiSwitch.addTarget(self, action: #selector(didToggleIsLoudNotificationEnabled), for: .valueChanged)
        return uiSwitch
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        let precalculatedDynamicTextColor = label.textColor
        
        label.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            let message = NSMutableAttributedString(
                string: "Alarms will ring and repeatedly vibrate despite your phone being silenced, locked, or in focus mode. ",
                attributes: [
                    .font: VisualConstant.FontConstant.secondaryColorDescLabel,
                    .foregroundColor: precalculatedDynamicTextColor as Any
                ]
            )
            
            message.append(NSAttributedString(
                string: "If Hound is terminated, Loud Alarms will not work properly.",
                attributes: [
                    .font: VisualConstant.FontConstant.emphasizedSecondaryColorDescLabel,
                    .foregroundColor: precalculatedDynamicTextColor as Any
                ])
            )
            
            return message
        }
        return label
    }()
    
    @objc private func didToggleIsLoudNotificationEnabled(_ sender: Any) {
        let beforeUpdateIsLoudNotificationEnabled = UserConfiguration.isLoudNotificationEnabled
        
        UserConfiguration.isLoudNotificationEnabled = isLoudNotificationEnabledSwitch.isOn
        
        let body = [KeyConstant.userConfigurationIsLoudNotificationEnabled.rawValue: UserConfiguration.isLoudNotificationEnabled]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.isLoudNotificationEnabled = beforeUpdateIsLoudNotificationEnabled
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsAlarmsLoudNotificationsTVC"
    
    // MARK: - Main
    
    override func prepareForReuse() {
        super.prepareForReuse()
        synchronizeValues(animated: false)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        synchronizeValues(animated: false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    // MARK: - Functions
    
    /// Updates the displayed values to reflect the values stored.
    private func synchronizeValues(animated: Bool) {
        isLoudNotificationEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled
        
        isLoudNotificationEnabledSwitch.setOn(UserConfiguration.isLoudNotificationEnabled, animated: animated)
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(isLoudNotificationEnabledSwitch)
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

        // isLoudNotificationEnabledSwitch
        NSLayoutConstraint.activate([
            isLoudNotificationEnabledSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            isLoudNotificationEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHoriSpacing),
            isLoudNotificationEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset * 2.0)
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
