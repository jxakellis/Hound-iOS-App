//
//  SettingsNotificationsAlarmsLoudNotificationsTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotificationsAlarmsLoudNotificationsTableViewCell: UITableViewCell {

    // MARK: - IB
    
    @IBOutlet private weak var isLoudNotificationEnabledSwitch: UISwitch!
    
    @IBAction private func didToggleIsLoudNotificationEnabled(_ sender: Any) {
        let beforeUpdateIsLoudNotificationEnabled = UserConfiguration.isLoudNotificationEnabled
        
        UserConfiguration.isLoudNotificationEnabled = isLoudNotificationEnabledSwitch.isOn
        
        let body = [KeyConstant.userConfigurationIsLoudNotificationEnabled.rawValue: UserConfiguration.isLoudNotificationEnabled]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error with communication the change to the server, therefore revert local values to previous state
                UserConfiguration.isLoudNotificationEnabled = beforeUpdateIsLoudNotificationEnabled
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
        isLoudNotificationEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled
    }
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()
        
        isLoudNotificationEnabledSwitch.setOn(UserConfiguration.isLoudNotificationEnabled, animated: animated)
    }

}
