//
//  SettingsFamilyMemberTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyMemberTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var fullNameLabel: GeneralUILabel!
    
    @IBOutlet private weak var rightChevronImageView: UIImageView!
    @IBOutlet private weak var rightChevronLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightChevronAspectRatio: NSLayoutConstraint!
    
    // MARK: - Functions
    
    func setup(forDisplayFullName displayFullName: String) {
        fullNameLabel.text = displayFullName
        
        let isUserFamilyHead = FamilyInformation.isUserFamilyHead
        // if the user is not the family head, that means the cell should not be selectable nor should we show the chevron that indicates selectability
        isUserInteractionEnabled = isUserFamilyHead
        rightChevronImageView.isHidden = !isUserFamilyHead
        
        rightChevronLeadingConstraint.constant = isUserFamilyHead ? 10.0 : 0.0
        
        if isUserFamilyHead == false {
            
            if let rightChevronAspectRatio = rightChevronAspectRatio {
                // upon cell reload, the rightChevronAspectRatio can be nil if deactived already
                NSLayoutConstraint.deactivate([rightChevronAspectRatio])
            }
            
            NSLayoutConstraint.activate([ rightChevronImageView.widthAnchor.constraint(equalToConstant: 0.0)])
        }
    }
    
}
