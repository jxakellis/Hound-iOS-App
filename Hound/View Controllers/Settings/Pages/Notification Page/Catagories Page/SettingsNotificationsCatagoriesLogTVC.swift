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

    @IBOutlet private weak var isLogNotificationEnabledSwitch: UISwitch!

    @IBAction private func didToggleIsLogNotificationEnabled(_ sender: Any) {
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

    override func awakeFromNib() {
        super.awakeFromNib()

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
