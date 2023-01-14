//
//  SettingsNotificationsCatagoriesLogTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNotificationsCatagoriesLogTableViewCell: UITableViewCell {
    
    // TO DO NOW create SettingsNotificationsCatagoriesLogTableViewCell
    
    // MARK: - Properties
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        synchronizeValues(animated: false)
    }

    // MARK: - Functions
    
    /// Updates the displayed isEnabled to reflect the state of isNotificationEnabled stored.
    func synchronizeIsEnabled() {
        
    }
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()
        
    }
}
