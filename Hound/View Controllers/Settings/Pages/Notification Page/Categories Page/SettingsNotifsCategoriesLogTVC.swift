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
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Log"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private lazy var isLogNotificationEnabledSwitch: GeneralUISwitch = {
        let uiSwitch = GeneralUISwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.isOn = true
        uiSwitch.addTarget(self, action: #selector(didToggleIsLogNotificationEnabled), for: .valueChanged)
        return uiSwitch
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 230, compressionResistancePriority: 230)
        label.text = "Receive notifications about your family's logs. Examples include: a user creating a log."
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
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
        isLogNotificationEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled
        
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

        // isLogNotificationEnabledSwitch
        NSLayoutConstraint.activate([
            isLogNotificationEnabledSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            isLogNotificationEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHoriSpacing),
            isLogNotificationEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset * 2.0)
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
