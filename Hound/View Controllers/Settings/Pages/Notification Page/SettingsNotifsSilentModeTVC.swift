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
    
    private let isSilentModeEnabledSwitch: GeneralUISwitch = {
        let uiSwitch = GeneralUISwitch(huggingPriority: 300, compressionResistancePriority: 300)
        uiSwitch.isOn = UserConfiguration.isSilentModeEnabled
        
        return uiSwitch
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
    
    private let silentModeStartHoursDatePicker: GeneralUIDatePicker = {
        let datePicker = GeneralUIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 5
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()
    
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
    
    private let silentModeEndHoursDatePicker: GeneralUIDatePicker = {
        let datePicker = GeneralUIDatePicker(huggingPriority: 240, compressionResistancePriority: 240)
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 5
        datePicker.preferredDatePickerStyle = .compact
        
        return datePicker
    }()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 290, compressionResistancePriority: 300)
        label.text = "Silent Hours"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 230, compressionResistancePriority: 230)
        label.text = "Configure a time range where you won't recieve notifications (including alarms)."
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let timeRangeToLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 260, compressionResistancePriority: 260)
        label.text = "to"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
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
        isSilentModeEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled
        
        silentModeStartHoursDatePicker.isEnabled = UserConfiguration.isNotificationEnabled
        
        silentModeEndHoursDatePicker.isEnabled = UserConfiguration.isNotificationEnabled
    }
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()
        
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
        
        // fixes issue with first time datepicker updates not triggering function
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.silentModeStartHoursDatePicker.setDate(
                Calendar.UTCCalendar.date(
                    bySettingHour: UserConfiguration.silentModeStartUTCHour,
                    minute: UserConfiguration.silentModeStartUTCMinute,
                    second: 0, of: Date()) ?? Date(),
                animated: animated)
            self.silentModeEndHoursDatePicker.setDate(
                Calendar.UTCCalendar.date(
                    bySettingHour: UserConfiguration.silentModeEndUTCHour,
                    minute: UserConfiguration.silentModeEndUTCMinute,
                    second: 0, of: Date()) ?? Date(),
                animated: animated)
        }
        
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(silentModeStartHoursDatePicker)
        contentView.addSubview(timeRangeToLabel)
        contentView.addSubview(silentModeEndHoursDatePicker)
        contentView.addSubview(isSilentModeEnabledSwitch)
        
        isSilentModeEnabledSwitch.addTarget(self, action: #selector(didToggleIsSilentModeEnabled), for: .valueChanged)
        silentModeStartHoursDatePicker.addTarget(self, action: #selector(didUpdateSilentModeStartHours), for: .valueChanged)
        silentModeEndHoursDatePicker.addTarget(self, action: #selector(didUpdateSilentModeEndHours), for: .valueChanged)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // headerLabel
        let headerLabelTop = headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Global.contentHoriInset)
        let headerLabelLeading = headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset)
        let headerLabelHeight = headerLabel.heightAnchor.constraint(equalToConstant: 25)
        
        // isSilentModeEnabledSwitch
        let isSilentModeEnabledSwitchLeading = isSilentModeEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10)
        let isSilentModeEnabledSwitchTrailing = isSilentModeEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40)
        let isSilentModeEnabledSwitchCenterY = isSilentModeEnabledSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor)
        
        // silentModeStartHoursDatePicker
        let silentModeStartHoursDatePickerTop = silentModeStartHoursDatePicker.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20)
        let silentModeStartHoursDatePickerLeading = silentModeStartHoursDatePicker.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor)
        let silentModeStartHoursDatePickerWidth = silentModeStartHoursDatePicker.widthAnchor.constraint(equalTo: silentModeStartHoursDatePicker.heightAnchor, multiplier: 2.75)
        
        // timeRangeToLabel
        let timeRangeToLabelLeading = timeRangeToLabel.leadingAnchor.constraint(equalTo: silentModeStartHoursDatePicker.trailingAnchor, constant: 10)
        let timeRangeToLabelCenterY = timeRangeToLabel.centerYAnchor.constraint(equalTo: silentModeStartHoursDatePicker.centerYAnchor)
        let timeRangeToLabelHeight = timeRangeToLabel.heightAnchor.constraint(equalToConstant: 35)
        
        // silentModeEndHoursDatePicker
        let silentModeEndHoursDatePickerLeading = silentModeEndHoursDatePicker.leadingAnchor.constraint(equalTo: timeRangeToLabel.trailingAnchor, constant: 10)
        let silentModeEndHoursDatePickerTrailing = silentModeEndHoursDatePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset)
        let silentModeEndHoursDatePickerCenterY = silentModeEndHoursDatePicker.centerYAnchor.constraint(equalTo: timeRangeToLabel.centerYAnchor)
        let silentModeEndHoursDatePickerWidth = silentModeEndHoursDatePicker.widthAnchor.constraint(equalTo: silentModeEndHoursDatePicker.heightAnchor, multiplier: 2.75)
        
        // descriptionLabel
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: timeRangeToLabel.bottomAnchor, constant: 15)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor)
        let descriptionLabelTrailing = descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset)
        let descriptionLabelBottom = descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Global.contentHoriInset)
        
        NSLayoutConstraint.activate([
            // headerLabel
            headerLabelTop, headerLabelLeading, headerLabelHeight,
            
            // isSilentModeEnabledSwitch
            isSilentModeEnabledSwitchLeading, isSilentModeEnabledSwitchTrailing, isSilentModeEnabledSwitchCenterY,
            
            // silentModeStartHoursDatePicker
            silentModeStartHoursDatePickerTop, silentModeStartHoursDatePickerLeading, silentModeStartHoursDatePickerWidth,
            
            // timeRangeToLabel
            timeRangeToLabelLeading, timeRangeToLabelCenterY, timeRangeToLabelHeight,
            
            // silentModeEndHoursDatePicker
            silentModeEndHoursDatePickerLeading, silentModeEndHoursDatePickerTrailing, silentModeEndHoursDatePickerCenterY, silentModeEndHoursDatePickerWidth,
            
            // descriptionLabel
            descriptionLabelTop, descriptionLabelLeading, descriptionLabelTrailing, descriptionLabelBottom
        ])
    }

}
