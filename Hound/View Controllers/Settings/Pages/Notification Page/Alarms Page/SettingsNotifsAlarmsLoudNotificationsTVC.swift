//
//  SettingsNotifsAlarmsLoudNotificationsTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsAlarmsLoudNotificationsTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    private let isLoudNotificationEnabledSwitch: GeneralUISwitch = {
        let uiSwitch = GeneralUISwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.isOn = UserConfiguration.isNotificationEnabled
        return uiSwitch
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
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Additional UI Elements
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Loud Alarms"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsAlarmsLoudNotificationsTVC"
    
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
        synchronizeValues(animated: false)
        
        let precalculatedDynamicTextColor = descriptionLabel.textColor
        
        descriptionLabel.attributedTextClosure = {
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
    }
    
    // MARK: - Functions
    
    /// Updates the displayed isEnabled to reflect the state of isNotificationEnabled stored.
    func synchronizeIsEnabled() {
        isLoudNotificationEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled
    }
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()
        
        isLoudNotificationEnabledSwitch.setOn(UserConfiguration.isLoudNotificationEnabled, animated: animated)
    }
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(isLoudNotificationEnabledSwitch)
        
        isLoudNotificationEnabledSwitch.addTarget(self, action: #selector(didToggleIsLoudNotificationEnabled), for: .valueChanged)
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        // isLoudNotificationEnabledSwitch
        let isLoudNotificationEnabledSwitchTop = isLoudNotificationEnabledSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Global.contentHoriInset)
        let isLoudNotificationEnabledSwitchLeading = isLoudNotificationEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10)
        let isLoudNotificationEnabledSwitchTrailing = isLoudNotificationEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40)
        let isLoudNotificationEnabledSwitchCenterY = isLoudNotificationEnabledSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor)

        // headerLabel
        let headerLabelLeading = headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset)

        // descriptionLabel
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: isLoudNotificationEnabledSwitch.bottomAnchor, constant: 7.5)
        let descriptionLabelBottom = descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Global.contentHoriInset)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset)
        let descriptionLabelTrailing = descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset)

        NSLayoutConstraint.activate([
            // Switch
            isLoudNotificationEnabledSwitchTop,
            isLoudNotificationEnabledSwitchLeading,
            isLoudNotificationEnabledSwitchTrailing,
            isLoudNotificationEnabledSwitchCenterY,

            // Header label
            headerLabelLeading,

            // Description label
            descriptionLabelTop,
            descriptionLabelBottom,
            descriptionLabelLeading,
            descriptionLabelTrailing
        ])
    }

}
