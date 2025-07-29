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
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 230, compressionResistancePriority: 230)
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 0
        
        label.attributedText = {
            let message = NSMutableAttributedString(
                string: "Recieve notifications about any of your family's reminders. ",
                attributes: [.font: Constant.Visual.Font.secondaryColorDescLabel]
            )
            
            message.append(NSAttributedString(
                string: "Notifications are also customizable for each individual reminder.",
                attributes: [.font: Constant.Visual.Font.emphasizedSecondaryColorDescLabel])
            )
            
            message.append(NSAttributedString(
                string: " Examples include: a reminder's alarm sounding.",
                attributes: [.font: Constant.Visual.Font.secondaryColorDescLabel])
            )
            
            return message
        }()
        
        return label
    }()
    
    private lazy var isReminderNotificationEnabledSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.isOn = true
        uiSwitch.addTarget(self, action: #selector(didToggleIsReminderNotificationEnabled), for: .valueChanged)
        return uiSwitch
    }()
    
    private lazy var disabledTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showDisabledBanner))
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    @objc private func didToggleIsReminderNotificationEnabled(_ sender: Any) {
        let beforeUpdatesReminderNotificationEnabled = UserConfiguration.isReminderNotificationEnabled
        
        UserConfiguration.isReminderNotificationEnabled = isReminderNotificationEnabledSwitch.isOn
        
        let body: JSONRequestBody = [Constant.Key.userConfigurationIsReminderNotificationEnabled.rawValue: .bool(UserConfiguration.isReminderNotificationEnabled)]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.isReminderNotificationEnabled = beforeUpdatesReminderNotificationEnabled
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    
    @objc private func showDisabledBanner(_ sender: Any) {
        guard UserConfiguration.isNotificationEnabled == false else { return }
        PresentationManager.enqueueBanner(
            forTitle: Constant.Visual.BannerText.noEditNotificationSettingsTitle,
            forSubtitle: Constant.Visual.BannerText.noEditNotificationSettingsSubtitle,
            forStyle: .warning
        )
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
        contentView.addGestureRecognizer(disabledTapGesture)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            headerLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            headerLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: contentView)
        ])
        
        // isReminderNotificationEnabledSwitch
        NSLayoutConstraint.activate([
            isReminderNotificationEnabledSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            isReminderNotificationEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            isReminderNotificationEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        ])
        
        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset)
        ])
    }
    
}
