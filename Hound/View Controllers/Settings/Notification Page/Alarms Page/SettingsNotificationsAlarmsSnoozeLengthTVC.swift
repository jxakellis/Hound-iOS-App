//
//  SettingsNotificationsAlarmsSnoozeLengthTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNotificationsAlarmsSnoozeLengthTableViewCell: UITableViewCell {

    // MARK: - IB
    
    @IBOutlet private weak var snoozeLengthDatePicker: UIDatePicker!
    
    @IBAction private func didUpdateSnoozeLength(_ sender: Any) {
        let beforeUpdateSnoozeLength = UserConfiguration.snoozeLength
        
        UserConfiguration.snoozeLength = snoozeLengthDatePicker.countDownDuration
        
        let body = [KeyConstant.userConfigurationSnoozeLength.rawValue: UserConfiguration.snoozeLength]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error with communication the change to the server, therefore revert local values to previous state
                UserConfiguration.snoozeLength = beforeUpdateSnoozeLength
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
        snoozeLengthDatePicker.isEnabled = UserConfiguration.isNotificationEnabled
    }
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()
        
        snoozeLengthDatePicker.countDownDuration = UserConfiguration.snoozeLength
        
        // fixes issue with first time datepicker updates not triggering function
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.snoozeLengthDatePicker.countDownDuration = UserConfiguration.snoozeLength
        }
    }

}
