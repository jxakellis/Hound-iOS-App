//
//  SettingsNotificationsAlarmsNotificationSoundsTableViewCellNotificationSoundTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/14/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNotificationsAlarmsNotificationSoundsTableViewCellNotificationSoundTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var notificationSoundLabel: ScaledUILabel!
    
    // MARK: - Functions
    
    /// isSelected and setSelected are used and modified by the system when a user physically clicks on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    var isCustomSelected: Bool = false
    
    // MARK: - Functions
    
    func setup(forNotificationSound notificationSound: String) {
        notificationSoundLabel.text = notificationSound
    }
    
    /// isSelected and setSelected are used and modified by the system when a user physically clicks on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelected(_ selected: Bool, animated: Bool) {
        // DO NOT INVOKE DEFAULT IMPLEMENTATION OF super.setSelected(selected, animated: animated)
        guard selected != isCustomSelected else {
            return
        }
        
        isCustomSelected = selected
        
        UIView.animate(withDuration: animated ? VisualConstant.AnimationConstant.setCustomSelected : 0.0) {
            self.contentView.backgroundColor = selected ? .systemBlue : .systemBackground
            self.notificationSoundLabel.textColor = selected ? .white : .label
        }
    }

}
