//
//  SettingsNotificationsCatagoriesReminderTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotificationsCatagoriesReminderTableViewCell: UITableViewCell {

    // MARK: - IB
    
    @IBOutlet private weak var isReminderNotificationEnabledSwitch: UISwitch!
    
    @IBAction private func didToggleIsReminderNotificationEnabled(_ sender: Any) {
        let beforeUpdatesReminderNotificationEnabled = UserConfiguration.isReminderNotificationEnabled
        
        UserConfiguration.isReminderNotificationEnabled = isReminderNotificationEnabledSwitch.isOn
        
        let body = [KeyConstant.userConfigurationIsReminderNotificationEnabled.rawValue: UserConfiguration.isReminderNotificationEnabled]
        
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error with communication the change to the server, therefore revert local values to previous state
                UserConfiguration.isReminderNotificationEnabled = beforeUpdatesReminderNotificationEnabled
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
        isReminderNotificationEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled
    }
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()
        
        isReminderNotificationEnabledSwitch.setOn(UserConfiguration.isReminderNotificationEnabled, animated: animated)
    }

}
