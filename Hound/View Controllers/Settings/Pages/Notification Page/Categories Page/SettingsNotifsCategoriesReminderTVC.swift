//
//  SettingsNotifsCategoriesReminderTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsCategoriesReminderTVC: UITableViewCell {

    // MARK: - Elements

    private let isReminderNotificationEnabledSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.contentMode = .scaleToFill
        uiSwitch.setContentHuggingPriority(UILayoutPriority(255), for: .horizontal)
        uiSwitch.setContentHuggingPriority(UILayoutPriority(255), for: .vertical)
        uiSwitch.setContentCompressionResistancePriority(UILayoutPriority(755), for: .horizontal)
        uiSwitch.setContentCompressionResistancePriority(UILayoutPriority(755), for: .vertical)
        uiSwitch.contentHorizontalAlignment = .center
        uiSwitch.contentVerticalAlignment = .center
        uiSwitch.isOn = true
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.onTintColor = .systemBlue
        
        return uiSwitch
    }()
    
    // MARK: - Additional UI Elements
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(751), for: .vertical)
        label.text = "Reminder"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(230), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(230), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(730), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(730), for: .vertical)
        label.text = "Recieve notifications about your family's reminders. Examples include: a reminder's alarm sounding."
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12.5, weight: .light)
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

    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGeneratedViews()
        synchronizeValues(animated: false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGeneratedViews()
        synchronizeValues(animated: false)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGeneratedViews()
        synchronizeValues(animated: false)
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

}

extension SettingsNotifsCategoriesReminderTVC {
    private func setupGeneratedViews() {
        addSubViews()
        setupConstraints()
    }

    private func addSubViews() {
        contentView.addSubview(headerLabel)
        contentView.addSubview(isReminderNotificationEnabledSwitch)
        contentView.addSubview(descriptionLabel)
        
        isReminderNotificationEnabledSwitch.addTarget(self, action: #selector(didToggleIsReminderNotificationEnabled), for: .valueChanged)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: isReminderNotificationEnabledSwitch.bottomAnchor, constant: 7.5),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.centerYAnchor.constraint(equalTo: isReminderNotificationEnabledSwitch.centerYAnchor),
        
            isReminderNotificationEnabledSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            isReminderNotificationEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10),
            isReminderNotificationEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
        
        ])
        
    }
}
