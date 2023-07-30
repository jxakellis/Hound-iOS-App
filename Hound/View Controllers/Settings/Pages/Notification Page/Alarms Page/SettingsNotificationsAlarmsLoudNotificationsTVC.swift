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
    
    @IBOutlet private weak var descriptionLabel: GeneralUILabel!
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        synchronizeValues(animated: false)
        
        let precalculatedDynamicTextColor = descriptionLabel.textColor
        print("textColor", precalculatedDynamicTextColor, precalculatedDynamicTextColor == .systemGray2, precalculatedDynamicTextColor == descriptionLabel.textColor)
        
        descriptionLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            let message = NSMutableAttributedString(
                string: "Alarms will ring and repeatedly vibrate despite your phone being silenced, locked, or in focus mode. ",
                attributes: [
                    .font: VisualConstant.FontConstant.secondaryLabelColorFeatureDescriptionLabel,
                    .foregroundColor: precalculatedDynamicTextColor as Any
                ]
            )
            
            message.append(NSAttributedString(
                string: "If Hound is terminated, Loud Alarms will not work properly.",
                attributes: [
                    .font: VisualConstant.FontConstant.emphasizedSecondaryLabelColorFeatureDescriptionLabel,
                    .foregroundColor: precalculatedDynamicTextColor as Any
                ])
            )
            
            return message
        }
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
