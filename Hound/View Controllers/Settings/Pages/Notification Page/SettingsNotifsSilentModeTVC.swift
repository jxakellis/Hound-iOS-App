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
    
    private let isSilentModeEnabledSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.contentMode = .scaleToFill
        uiSwitch.setContentHuggingPriority(UILayoutPriority(300), for: .horizontal)
        uiSwitch.setContentHuggingPriority(UILayoutPriority(300), for: .vertical)
        uiSwitch.setContentCompressionResistancePriority(UILayoutPriority(800), for: .horizontal)
        uiSwitch.setContentCompressionResistancePriority(UILayoutPriority(800), for: .vertical)
        uiSwitch.contentHorizontalAlignment = .center
        uiSwitch.contentVerticalAlignment = .center
        uiSwitch.isOn = UserConfiguration.isSilentModeEnabled
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.onTintColor = .systemBlue
        
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
    
    private let silentModeStartHoursDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.contentMode = .scaleToFill
        datePicker.contentHorizontalAlignment = .center
        datePicker.contentVerticalAlignment = .center
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 5
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
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
    
    private let silentModeEndHoursDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.contentMode = .scaleToFill
        datePicker.setContentHuggingPriority(UILayoutPriority(240), for: .horizontal)
        datePicker.setContentHuggingPriority(UILayoutPriority(240), for: .vertical)
        datePicker.setContentCompressionResistancePriority(UILayoutPriority(740), for: .horizontal)
        datePicker.setContentCompressionResistancePriority(UILayoutPriority(740), for: .vertical)
        datePicker.contentHorizontalAlignment = .center
        datePicker.contentVerticalAlignment = .center
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 5
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        return datePicker
    }()
    
    // MARK: - Additional UI Elements
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(290), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(290), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(800), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(800), for: .vertical)
        label.text = "Silent Hours"
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
        label.text = "Configure a time range where you won't recieve notifications (including alarms)."
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
    
    private let timeRangeToLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(260), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(260), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(760), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(760), for: .vertical)
        label.text = "to"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        synchronizeValues(animated: false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        synchronizeValues(animated: false)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        synchronizeValues(animated: false)
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
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.heightAnchor.constraint(equalToConstant: 25),
            
            silentModeStartHoursDatePicker.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            silentModeStartHoursDatePicker.widthAnchor.constraint(equalTo: silentModeStartHoursDatePicker.heightAnchor, multiplier: 2.75/1),
            
            timeRangeToLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            timeRangeToLabel.leadingAnchor.constraint(equalTo: silentModeStartHoursDatePicker.trailingAnchor, constant: 10),
            timeRangeToLabel.centerYAnchor.constraint(equalTo: silentModeStartHoursDatePicker.centerYAnchor),
            timeRangeToLabel.heightAnchor.constraint(equalToConstant: 35),
            
            silentModeEndHoursDatePicker.leadingAnchor.constraint(equalTo: timeRangeToLabel.trailingAnchor, constant: 10),
            silentModeEndHoursDatePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            silentModeEndHoursDatePicker.centerYAnchor.constraint(equalTo: timeRangeToLabel.centerYAnchor),
            silentModeEndHoursDatePicker.widthAnchor.constraint(equalTo: silentModeEndHoursDatePicker.heightAnchor, multiplier: 2.75/1),
            
            isSilentModeEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10),
            isSilentModeEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            isSilentModeEnabledSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: timeRangeToLabel.bottomAnchor, constant: 15),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
        ])
        
    }
}
