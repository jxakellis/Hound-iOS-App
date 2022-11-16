//
//  SettingsCopyrightTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/14/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsCopyrightTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet private weak var version: ScaledUILabel!
    
    @IBOutlet private weak var copyright: ScaledUILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.version.text = "Version \(UIApplication.appVersion)"
        self.copyright.text = "© \(Calendar.localCalendar.component(.year, from: Date())) Jonathan Xakellis"
    }

}
