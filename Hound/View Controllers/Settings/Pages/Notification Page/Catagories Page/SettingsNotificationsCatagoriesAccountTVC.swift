//
//  SettingsNotificationsCatagoriesAccountTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNotificationsCatagoriesAccountTableViewCell: UITableViewCell {
    
    // NO-OP class. Account notifications are always enabled so there is no point to making a functional, non-static cell
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
}
