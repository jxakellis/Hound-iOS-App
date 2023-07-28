//
//  SettingsNotificationsCatagoriesFamilyTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNotificationsCatagoriesFamilyTableViewCell: UITableViewCell {

    // NO-OP class. Family notifications are always enabled so there is no point to making a functional, non-static cell
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

}
