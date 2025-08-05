//
//  SettingsNotifsSilentModeTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsSilentModeTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    private let headerLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 300)
        label.text = "Silent Hours"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private lazy var isSilentModeEnabledSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 300, compressionResistancePriority: 300)
        uiSwitch.isOn = UserConfiguration.isSilentModeEnabled
        uiSwitch.addTarget(self, action: #selector(didToggleIsSilentModeEnabled), for: .valueChanged)
        return uiSwitch
    }()
    
    private lazy var silentModeStartHoursDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 280, compressionResistancePriority: 280)
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = Constant.Development.minuteInterval
        datePicker.preferredDatePickerStyle = .compact
        datePicker.timeZone = Calendar.user.timeZone
        datePicker.addTarget(self, action: #selector(didUpdateSilentModeStartHours), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var silentModeEndHoursDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 270, compressionResistancePriority: 270)
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = Constant.Development.minuteInterval
        datePicker.preferredDatePickerStyle = .compact
        datePicker.timeZone = Calendar.user.timeZone
        datePicker.addTarget(self, action: #selector(didUpdateSilentModeEndHours), for: .valueChanged)
        return datePicker
    }()
    
    private let timeRangeToLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.text = "to"
        label.font = Constant.Visual.Font.primaryRegularLabel
        return label
    }()
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.text = "Configure a time range where you won't recieve notifications (including alarms)."
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    private lazy var disabledTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showDisabledBanner))
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    @objc private func showDisabledBanner(_ sender: Any) {
        guard UserConfiguration.isNotificationEnabled == false else { return }
        PresentationManager.enqueueBanner(
            title: Constant.Visual.BannerText.noEditNotificationSettingsTitle,
            subtitle: Constant.Visual.BannerText.noEditNotificationSettingsSubtitle,
            style: .warning
        )
    }
    
    @objc private func didToggleIsSilentModeEnabled(_ sender: Any) {
        let beforeUpdateIsSilentModeEnabled = UserConfiguration.isSilentModeEnabled
        
        UserConfiguration.isSilentModeEnabled = isSilentModeEnabledSwitch.isOn
        
        let body: JSONRequestBody = [Constant.Key.userConfigurationIsSilentModeEnabled.rawValue: .bool(UserConfiguration.isSilentModeEnabled)]
        
        // cant choose silent mode time when silent mode is disabled
        synchronizeDatePickers(animated: true)
        
        UserRequest.update(errorAlert: .automaticallyAlertOnlyForFailure, body: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.isSilentModeEnabled = beforeUpdateIsSilentModeEnabled
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    
    @objc private func didUpdateSilentModeStartHours(_ sender: Any) {
        let beforeUpdateSilentModeStartHour = UserConfiguration.silentModeStartHour
        let beforeUpdateSilentModeStartMinute = UserConfiguration.silentModeStartMinute

        let calendar = Calendar.user
        UserConfiguration.silentModeStartHour = calendar.component(.hour, from: silentModeStartHoursDatePicker.date)
        UserConfiguration.silentModeStartMinute = calendar.component(.minute, from: silentModeStartHoursDatePicker.date)

        let body: JSONRequestBody = [
            Constant.Key.userConfigurationSilentModeStartHour.rawValue: .int(UserConfiguration.silentModeStartHour),
            Constant.Key.userConfigurationSilentModeStartMinute.rawValue: .int(UserConfiguration.silentModeStartMinute)
        ]

        UserRequest.update(errorAlert: .automaticallyAlertOnlyForFailure, body: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                UserConfiguration.silentModeStartHour = beforeUpdateSilentModeStartHour
                UserConfiguration.silentModeStartMinute = beforeUpdateSilentModeStartMinute
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    
    @objc private func didUpdateSilentModeEndHours(_ sender: Any) {
        let beforeUpdateSilentModeEndHour = UserConfiguration.silentModeEndHour
        let beforeUpdateSilentModeEndMinute = UserConfiguration.silentModeEndMinute

        let calendar = Calendar.user
        UserConfiguration.silentModeEndHour = calendar.component(.hour, from: silentModeEndHoursDatePicker.date)
        UserConfiguration.silentModeEndMinute = calendar.component(.minute, from: silentModeEndHoursDatePicker.date)

        let body: JSONRequestBody = [
            Constant.Key.userConfigurationSilentModeEndHour.rawValue: .int(UserConfiguration.silentModeEndHour),
            Constant.Key.userConfigurationSilentModeEndMinute.rawValue: .int(UserConfiguration.silentModeEndMinute)
        ]

        UserRequest.update(errorAlert: .automaticallyAlertOnlyForFailure, body: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                UserConfiguration.silentModeEndHour = beforeUpdateSilentModeEndHour
                UserConfiguration.silentModeEndMinute = beforeUpdateSilentModeEndMinute
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsSilentModeTVC"
    
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
        isSilentModeEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled
        isSilentModeEnabledSwitch.setOn(UserConfiguration.isSilentModeEnabled, animated: animated)
        synchronizeDatePickers(animated: animated)
    }
    
    private func synchronizeDatePickers(animated: Bool) {
        silentModeStartHoursDatePicker.isEnabled = UserConfiguration.isNotificationEnabled && UserConfiguration.isSilentModeEnabled
        silentModeEndHoursDatePicker.isEnabled = UserConfiguration.isNotificationEnabled && UserConfiguration.isSilentModeEnabled

        let calendar = Calendar.user
        silentModeStartHoursDatePicker.setDate(
            calendar.date(
                bySettingHour: UserConfiguration.silentModeStartHour,
                minute: UserConfiguration.silentModeStartMinute,
                second: 0, of: Date()
            ) ?? Date(),
            animated: animated
        )
        silentModeEndHoursDatePicker.setDate(
            calendar.date(
                bySettingHour: UserConfiguration.silentModeEndHour,
                minute: UserConfiguration.silentModeEndMinute,
                second: 0, of: Date()
            ) ?? Date(),
            animated: animated
        )
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(isSilentModeEnabledSwitch)
        contentView.addSubview(silentModeStartHoursDatePicker)
        contentView.addSubview(timeRangeToLabel)
        contentView.addSubview(silentModeEndHoursDatePicker)
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
        
        // isNotificationEnabledSwitch
        NSLayoutConstraint.activate([
            isSilentModeEnabledSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            isSilentModeEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            isSilentModeEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        ])
        
        // silentModeStartHoursDatePicker
        NSLayoutConstraint.activate([
            silentModeStartHoursDatePicker.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            silentModeStartHoursDatePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            silentModeStartHoursDatePicker.createHeightMultiplier(Constant.Constraint.Input.segmentedHeightMultiplier, relativeToWidthOf: contentView),
            silentModeStartHoursDatePicker.createMaxHeight(Constant.Constraint.Input.segmentedMaxHeight),
            silentModeStartHoursDatePicker.createAspectRatio(2.75)
        ])
        
        // timeRangeToLabel
        NSLayoutConstraint.activate([
            timeRangeToLabel.leadingAnchor.constraint(equalTo: silentModeStartHoursDatePicker.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            timeRangeToLabel.centerYAnchor.constraint(equalTo: silentModeStartHoursDatePicker.centerYAnchor),
            timeRangeToLabel.heightAnchor.constraint(equalTo: silentModeStartHoursDatePicker.heightAnchor)
        ])
        
        // silentModeStartHoursDatePicker
        NSLayoutConstraint.activate([
            silentModeEndHoursDatePicker.leadingAnchor.constraint(equalTo: timeRangeToLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            silentModeEndHoursDatePicker.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            silentModeEndHoursDatePicker.centerYAnchor.constraint(equalTo: silentModeStartHoursDatePicker.centerYAnchor),
            silentModeEndHoursDatePicker.heightAnchor.constraint(equalTo: silentModeStartHoursDatePicker.heightAnchor),
            silentModeEndHoursDatePicker.widthAnchor.constraint(equalTo: silentModeStartHoursDatePicker.widthAnchor)
        ])
        
        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: silentModeStartHoursDatePicker.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset)
        ])
    }
    
}
