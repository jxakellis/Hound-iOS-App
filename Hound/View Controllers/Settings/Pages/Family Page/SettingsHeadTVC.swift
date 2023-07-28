//
//  SettingsFamilyHeadTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyHeadTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var fullNameLabel: ScaledUILabel!
    
    // MARK: - Main
    
    override func awakeFromNib() {
        self.selectionStyle = .none
    }
    
    // MARK: - Functions
    
    func setup(forDisplayFullName displayFullName: String) {
        fullNameLabel.text = displayFullName
    }
    
}
