//
//  SettingsNotifsCategoriesLogTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsCategoriesLogTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    private let isLogNotificationEnabledSwitch: GeneralUISwitch = {
        let uiSwitch = GeneralUISwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.isOn = true
        
        return uiSwitch
    }()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Log"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 230, compressionResistancePriority: 230)
        label.text = "Receive notifications about your family's logs. Examples include: a user creating a log."
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    @objc private func didToggleIsLogNotificationEnabled(_ sender: Any) {
        let beforeUpdatesLogNotificationEnabled = UserConfiguration.isLogNotificationEnabled
        
        UserConfiguration.isLogNotificationEnabled = isLogNotificationEnabledSwitch.isOn
        
        let body = [KeyConstant.userConfigurationIsLogNotificationEnabled.rawValue: UserConfiguration.isLogNotificationEnabled]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.isLogNotificationEnabled = beforeUpdatesLogNotificationEnabled
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsCategoriesLogTVC"
    
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
        isLogNotificationEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled
    }
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()
        
        isLogNotificationEnabledSwitch.setOn(UserConfiguration.isLogNotificationEnabled, animated: animated)
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(isLogNotificationEnabledSwitch)
        contentView.addSubview(descriptionLabel)
        
        isLogNotificationEnabledSwitch.addTarget(self, action: #selector(didToggleIsLogNotificationEnabled), for: .valueChanged)
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        // isLogNotificationEnabledSwitch
        let isLogNotificationEnabledSwitchTop = isLogNotificationEnabledSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20)
        let isLogNotificationEnabledSwitchLeading = isLogNotificationEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10)
        let isLogNotificationEnabledSwitchTrailing = isLogNotificationEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40)

        // headerLabel
        let headerLabelLeading = headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        let headerLabelCenterY = headerLabel.centerYAnchor.constraint(equalTo: isLogNotificationEnabledSwitch.centerYAnchor)

        // descriptionLabel
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: isLogNotificationEnabledSwitch.bottomAnchor, constant: 7.5)
        let descriptionLabelBottom = descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        let descriptionLabelTrailing = descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)

        NSLayoutConstraint.activate([
            // isLogNotificationEnabledSwitch
            isLogNotificationEnabledSwitchTop, isLogNotificationEnabledSwitchLeading, isLogNotificationEnabledSwitchTrailing,

            // headerLabel
            headerLabelLeading, headerLabelCenterY,

            // descriptionLabel
            descriptionLabelTop, descriptionLabelBottom, descriptionLabelLeading, descriptionLabelTrailing
        ])
    }

}
