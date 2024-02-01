//
//  SettingsNotificationsSilentModeTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotificationsSilentModeTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private weak var isSilentModeEnabledSwitch: UISwitch!

    @IBAction private func didToggleIsSilentModeEnabled(_ sender: Any) {
        let beforeUpdateIsSilentModeEnabled = UserConfiguration.isSilentModeEnabled

        UserConfiguration.isSilentModeEnabled = isSilentModeEnabledSwitch.isOn

        let body = [KeyConstant.userConfigurationIsSilentModeEnabled.rawValue: UserConfiguration.isSilentModeEnabled]

        UserRequest.update(invokeErrorManager: true, forBody: body) { requestWasSuccessful, _, _ in
            if requestWasSuccessful == false {
                // error with communication the change to the server, therefore revert local values to previous state
                UserConfiguration.isSilentModeEnabled = beforeUpdateIsSilentModeEnabled
                self.synchronizeValues(animated: true)
            }
        }
    }

    @IBOutlet private weak var silentModeStartHoursDatePicker: UIDatePicker!

    @IBAction private func didUpdateSilentModeStartHours(_ sender: Any) {
        let beforeUpdateSilentModeStartUTCHour = UserConfiguration.silentModeStartUTCHour
        let beforeUpdateSilentModeStartUTCMinute = UserConfiguration.silentModeStartUTCMinute

        UserConfiguration.silentModeStartUTCHour = Calendar.UTCCalendar.component(.hour, from: silentModeStartHoursDatePicker.date)
        UserConfiguration.silentModeStartUTCMinute = Calendar.UTCCalendar.component(.minute, from: silentModeStartHoursDatePicker.date)

        let body = [KeyConstant.userConfigurationSilentModeStartUTCHour.rawValue: UserConfiguration.silentModeStartUTCHour,
                    KeyConstant.userConfigurationSilentModeStartUTCMinute.rawValue: UserConfiguration.silentModeStartUTCMinute]

        UserRequest.update(invokeErrorManager: true, forBody: body) { requestWasSuccessful, _, _ in
            if requestWasSuccessful == false {
                // error with communication the change to the server, therefore revert local values to previous state
                UserConfiguration.silentModeStartUTCHour = beforeUpdateSilentModeStartUTCHour
                UserConfiguration.silentModeStartUTCMinute = beforeUpdateSilentModeStartUTCMinute
                self.synchronizeValues(animated: true)
            }
        }
    }

    @IBOutlet private weak var silentModeEndHoursDatePicker: UIDatePicker!

    @IBAction private func didUpdateSilentModeEndHours(_ sender: Any) {
        let beforeUpdateSilentModeEndUTCHour = UserConfiguration.silentModeEndUTCHour
        let beforeUpdateSilentModeEndUTCMinute = UserConfiguration.silentModeEndUTCMinute

        UserConfiguration.silentModeEndUTCHour = Calendar.UTCCalendar.component(.hour, from: silentModeEndHoursDatePicker.date)
        UserConfiguration.silentModeEndUTCMinute = Calendar.UTCCalendar.component(.minute, from: silentModeEndHoursDatePicker.date)

        let body = [KeyConstant.userConfigurationSilentModeEndUTCHour.rawValue: UserConfiguration.silentModeEndUTCHour,
                    KeyConstant.userConfigurationSilentModeEndUTCMinute.rawValue: UserConfiguration.silentModeEndUTCMinute]

        UserRequest.update(invokeErrorManager: true, forBody: body) { requestWasSuccessful, _, _ in
            if requestWasSuccessful == false {
                // error with communication the change to the server, therefore revert local values to previous state
                UserConfiguration.silentModeEndUTCHour = beforeUpdateSilentModeEndUTCHour
                UserConfiguration.silentModeEndUTCMinute = beforeUpdateSilentModeEndUTCMinute
                self.synchronizeValues(animated: true)
            }
        }
    }

    // MARK: - Main

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

}
