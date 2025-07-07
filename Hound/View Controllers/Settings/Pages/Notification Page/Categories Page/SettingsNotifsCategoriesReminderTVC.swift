//
//  SettingsNotifsCategoriesReminderTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsCategoriesReminderTVC: HoundTableViewCell {

    // MARK: - Elements
    
    private let headerLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Reminder"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 230, compressionResistancePriority: 230)
        label.text = "Recieve notifications about your family's reminders. Examples include: a reminder's alarm sounding."
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private lazy var isReminderNotificationEnabledSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.isOn = true
        uiSwitch.addTarget(self, action: #selector(didToggleIsReminderNotificationEnabled), for: .valueChanged)
        return uiSwitch
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
        isReminderNotificationEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled

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
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVerticalInset),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            headerLabel.createMaxHeight(ConstraintConstant.Text.sectionLabelMaxHeight),
            headerLabel.createHeightMultiplier(ConstraintConstant.Text.sectionLabelHeightMultipler, relativeToWidthOf: contentView)
        ])

        // isReminderNotificationEnabledSwitch
        NSLayoutConstraint.activate([
            isReminderNotificationEnabledSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            isReminderNotificationEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            isReminderNotificationEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset * 2.0)
        ])

        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVerticalInset)
        ])
    }

}
