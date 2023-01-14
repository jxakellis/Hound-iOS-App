//
//  SettingsNotificationsAlarmsLoudNotificationsTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNotificationsAlarmsLoudNotificationsTableViewCell: UITableViewCell {

    // MARK: - IB
    
    @IBOutlet private weak var isLoudNotificationSwitch: UISwitch!
    
    @IBAction private func didToggleIsLoudNotification(_ sender: Any) {
        let beforeUpdateIsLoudNotification = UserConfiguration.isLoudNotification
        
        UserConfiguration.isLoudNotification = isLoudNotificationSwitch.isOn
        
        let body = [KeyConstant.userConfigurationIsLoudNotification.rawValue: UserConfiguration.isLoudNotification]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error with communication the change to the server, therefore revert local values to previous state
                UserConfiguration.isLoudNotification = beforeUpdateIsLoudNotification
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
        isLoudNotificationSwitch.isEnabled = UserConfiguration.isNotificationEnabled
    }
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()
        
        isLoudNotificationSwitch.setOn(UserConfiguration.isLoudNotification, animated: animated)
    }

}
