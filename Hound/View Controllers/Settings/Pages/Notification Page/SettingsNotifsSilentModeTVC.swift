//
//  SettingsNotifsSilentModeTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsSilentModeTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 290, compressionResistancePriority: 300)
        label.text = "Silent Hours"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private lazy var isSilentModeEnabledSwitch: GeneralUISwitch = {
        let uiSwitch = GeneralUISwitch(huggingPriority: 300, compressionResistancePriority: 300)
        uiSwitch.isOn = UserConfiguration.isSilentModeEnabled
        uiSwitch.addTarget(self, action: #selector(didToggleIsSilentModeEnabled), for: .valueChanged)
        return uiSwitch
    }()
    
    private lazy var silentModeStartHoursDatePicker: GeneralUIDatePicker = {
        let datePicker = GeneralUIDatePicker(huggingPriority: 280, compressionResistancePriority: 280)
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 5
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(didUpdateSilentModeStartHours), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var silentModeEndHoursDatePicker: GeneralUIDatePicker = {
        let datePicker = GeneralUIDatePicker(huggingPriority: 270, compressionResistancePriority: 270)
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 5
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(didUpdateSilentModeEndHours), for: .valueChanged)
        return datePicker
    }()
    
    private let timeRangeToLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.text = "to"
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.text = "Configure a time range where you won't recieve notifications (including alarms)."
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    @objc private func didToggleIsSilentModeEnabled(_ sender: Any) {
        let beforeUpdateIsSilentModeEnabled = UserConfiguration.isSilentModeEnabled
        
        UserConfiguration.isSilentModeEnabled = isSilentModeEnabledSwitch.isOn
        
        let body = [KeyConstant.userConfigurationIsSilentModeEnabled.rawValue: UserConfiguration.isSilentModeEnabled]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.isSilentModeEnabled = beforeUpdateIsSilentModeEnabled
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    
    @objc private func didUpdateSilentModeStartHours(_ sender: Any) {
        let beforeUpdateSilentModeStartUTCHour = UserConfiguration.silentModeStartUTCHour
        let beforeUpdateSilentModeStartUTCMinute = UserConfiguration.silentModeStartUTCMinute
        
        UserConfiguration.silentModeStartUTCHour = Calendar.UTCCalendar.component(.hour, from: silentModeStartHoursDatePicker.date)
        UserConfiguration.silentModeStartUTCMinute = Calendar.UTCCalendar.component(.minute, from: silentModeStartHoursDatePicker.date)
        
        let body = [KeyConstant.userConfigurationSilentModeStartUTCHour.rawValue: UserConfiguration.silentModeStartUTCHour,
                    KeyConstant.userConfigurationSilentModeStartUTCMinute.rawValue: UserConfiguration.silentModeStartUTCMinute]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.silentModeStartUTCHour = beforeUpdateSilentModeStartUTCHour
                UserConfiguration.silentModeStartUTCMinute = beforeUpdateSilentModeStartUTCMinute
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    
    @objc private func didUpdateSilentModeEndHours(_ sender: Any) {
        let beforeUpdateSilentModeEndUTCHour = UserConfiguration.silentModeEndUTCHour
        let beforeUpdateSilentModeEndUTCMinute = UserConfiguration.silentModeEndUTCMinute
        
        UserConfiguration.silentModeEndUTCHour = Calendar.UTCCalendar.component(.hour, from: silentModeEndHoursDatePicker.date)
        UserConfiguration.silentModeEndUTCMinute = Calendar.UTCCalendar.component(.minute, from: silentModeEndHoursDatePicker.date)
        
        let body = [KeyConstant.userConfigurationSilentModeEndUTCHour.rawValue: UserConfiguration.silentModeEndUTCHour,
                    KeyConstant.userConfigurationSilentModeEndUTCMinute.rawValue: UserConfiguration.silentModeEndUTCMinute]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.silentModeEndUTCHour = beforeUpdateSilentModeEndUTCHour
                UserConfiguration.silentModeEndUTCMinute = beforeUpdateSilentModeEndUTCMinute
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
        silentModeStartHoursDatePicker.isEnabled = UserConfiguration.isNotificationEnabled
        silentModeEndHoursDatePicker.isEnabled = UserConfiguration.isNotificationEnabled
        
        isSilentModeEnabledSwitch.setOn(UserConfiguration.isSilentModeEnabled, animated: animated)
        silentModeStartHoursDatePicker.setDate(
            Calendar.UTCCalendar.date(
                bySettingHour: UserConfiguration.silentModeStartUTCHour,
                minute: UserConfiguration.silentModeStartUTCMinute,
                second: 0, of: Date()) ?? Date(),
            animated: animated)
        silentModeEndHoursDatePicker.setDate(
            Calendar.UTCCalendar.date(
                bySettingHour: UserConfiguration.silentModeEndUTCHour,
                minute: UserConfiguration.silentModeEndUTCMinute,
                second: 0, of: Date()) ?? Date(),
            animated: animated)
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
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Spacing.contentAbsVertInset),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            headerLabel.createMaxHeight( ConstraintConstant.Text.sectionLabelMaxHeight),
            headerLabel.createHeightMultiplier(ConstraintConstant.Text.sectionLabelHeightMultipler, relativeToWidthOf: contentView)
        ])
        
        // isNotificationEnabledSwitch
        NSLayoutConstraint.activate([
            isSilentModeEnabledSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            isSilentModeEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHoriSpacing),
            isSilentModeEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset * 2.0)
        ])
        
        // silentModeStartHoursDatePicker
        NSLayoutConstraint.activate([
            silentModeStartHoursDatePicker.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVertSpacing),
            silentModeStartHoursDatePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            silentModeStartHoursDatePicker.createHeightMultiplier(ConstraintConstant.Input.segmentedHeightMultiplier, relativeToWidthOf: contentView),
            silentModeStartHoursDatePicker.createMaxHeight(ConstraintConstant.Input.segmentedMaxHeight),
            silentModeStartHoursDatePicker.createAspectRatio(2.75)
        ])
        
        // timeRangeToLabel
        NSLayoutConstraint.activate([
            timeRangeToLabel.leadingAnchor.constraint(equalTo: silentModeStartHoursDatePicker.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHoriSpacing),
            timeRangeToLabel.centerYAnchor.constraint(equalTo: silentModeStartHoursDatePicker.centerYAnchor),
            timeRangeToLabel.heightAnchor.constraint(equalTo: silentModeStartHoursDatePicker.heightAnchor)
        ])
        
        // silentModeStartHoursDatePicker
        NSLayoutConstraint.activate([
            silentModeEndHoursDatePicker.leadingAnchor.constraint(equalTo: timeRangeToLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHoriSpacing),
            silentModeEndHoursDatePicker.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            silentModeEndHoursDatePicker.centerYAnchor.constraint(equalTo: silentModeStartHoursDatePicker.centerYAnchor),
            silentModeEndHoursDatePicker.heightAnchor.constraint(equalTo: silentModeStartHoursDatePicker.heightAnchor),
            silentModeEndHoursDatePicker.widthAnchor.constraint(equalTo: silentModeStartHoursDatePicker.widthAnchor)
        ])
        
        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: silentModeStartHoursDatePicker.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVertSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Spacing.contentAbsVertInset)
        ])
    }

}
