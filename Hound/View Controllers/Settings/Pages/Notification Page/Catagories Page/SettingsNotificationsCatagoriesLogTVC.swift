//
//  SettingsNotificationsCatagoriesLogTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotificationsCatagoriesLogTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    private let isLogNotificationEnabledSwitch: UISwitch = {
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
        label.text = "Log"
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
        label.text = "Receive notifications about your family's logs. Examples include: a user creating a log."
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
        isLogNotificationEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled
    }
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()
        
        isLogNotificationEnabledSwitch.setOn(UserConfiguration.isLogNotificationEnabled, animated: animated)
    }
}

extension SettingsNotificationsCatagoriesLogTableViewCell {
    func setupGeneratedViews() {
        
        addSubViews()
        setupConstraints()
    }
    
    func addSubViews() {
        contentView.addSubview(headerLabel)
        contentView.addSubview(isLogNotificationEnabledSwitch)
        contentView.addSubview(descriptionLabel)
        
        isLogNotificationEnabledSwitch.addTarget(self, action: #selector(didToggleIsLogNotificationEnabled), for: .valueChanged)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: isLogNotificationEnabledSwitch.bottomAnchor, constant: 7.5),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            isLogNotificationEnabledSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            isLogNotificationEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10),
            isLogNotificationEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.centerYAnchor.constraint(equalTo: isLogNotificationEnabledSwitch.centerYAnchor),
            
        ])
        
    }
}
