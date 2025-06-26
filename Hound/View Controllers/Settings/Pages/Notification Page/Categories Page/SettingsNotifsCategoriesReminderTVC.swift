//
//  SettingsNotifsCategoriesReminderTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO VERIFY UI
final class SettingsNotifsCategoriesReminderTVC: GeneralUITableViewCell {

    // MARK: - Elements

    private let isReminderNotificationEnabledSwitch: GeneralUISwitch = {
        let uiSwitch = GeneralUISwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.isOn = true
        
        return uiSwitch
    }()
    
    // MARK: - Additional UI Elements
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Reminder"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 230, compressionResistancePriority: 230)
        label.text = "Recieve notifications about your family's reminders. Examples include: a reminder's alarm sounding."
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
    }()

    @objc private func didToggleIsReminderNotificationEnabled(_ sender: Any) {
        let beforeUpdatesReminderNotificationEnabled = UserConfiguration.isReminderNotificationEnabled

        UserConfiguration.isReminderNotificationEnabled = isReminderNotificationEnabledSwitch.isOn

        let body = [KeyConstant.userConfigurationIsReminderNotificationEnabled.rawValue: UserConfiguration.isReminderNotificationEnabled]

        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.isReminderNotificationEnabled = beforeUpdatesReminderNotificationEnabled
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsCategoriesReminderTVC"

    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        synchronizeValues(animated: false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }

    // MARK: - Functions

    /// Updates the displayed isEnabled to reflect the state of isNotificationEnabled stored.
    func synchronizeIsEnabled() {
        isReminderNotificationEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled
    }

    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()

        isReminderNotificationEnabledSwitch.setOn(UserConfiguration.isReminderNotificationEnabled, animated: animated)
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(isReminderNotificationEnabledSwitch)
        contentView.addSubview(descriptionLabel)
        
        isReminderNotificationEnabledSwitch.addTarget(self, action: #selector(didToggleIsReminderNotificationEnabled), for: .valueChanged)
    }

    override func setupConstraints() {
        super.setupConstraints()
        
        // isReminderNotificationEnabledSwitch
        let isReminderNotificationEnabledSwitchTop = isReminderNotificationEnabledSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Global.contentAbsHoriInset)
        let isReminderNotificationEnabledSwitchLeading = isReminderNotificationEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10)
        let isReminderNotificationEnabledSwitchTrailing = isReminderNotificationEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40)
        
        // headerLabel
        let headerLabelLeading = headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentAbsHoriInset)
        let headerLabelCenterY = headerLabel.centerYAnchor.constraint(equalTo: isReminderNotificationEnabledSwitch.centerYAnchor)
        
        // descriptionLabel
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: isReminderNotificationEnabledSwitch.bottomAnchor, constant: 7.5)
        let descriptionLabelBottom = descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Global.contentAbsHoriInset)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentAbsHoriInset)
        let descriptionLabelTrailing = descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Global.contentAbsHoriInset)
        
        NSLayoutConstraint.activate([
            // Switch
            isReminderNotificationEnabledSwitchTop,
            isReminderNotificationEnabledSwitchLeading,
            isReminderNotificationEnabledSwitchTrailing,
            
            // Header label
            headerLabelLeading,
            headerLabelCenterY,
            
            // Description label
            descriptionLabelTop,
            descriptionLabelBottom,
            descriptionLabelLeading,
            descriptionLabelTrailing
        ])
    }

}
