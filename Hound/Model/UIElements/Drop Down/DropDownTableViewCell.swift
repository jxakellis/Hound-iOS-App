//
//  DropDownParentDogTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/2/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// NOT final class
class DropDownTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet weak var label: ScaledUILabel! // swiftlint:disable:this private_outlet
    
    @IBOutlet private weak var leading: NSLayoutConstraint!
    
    @IBOutlet private weak var trailing: NSLayoutConstraint!
    
    // MARK: - Properties
    
    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    private(set) var isCustomSelected: Bool = false
    
    // MARK: - Functions
    
    func adjustLeadingTrailing(newConstant: CGFloat) {
        leading.constant = newConstant
        trailing.constant = newConstant
    }
    
    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelectedTableViewCell(forSelected selected: Bool) {
        // DO NOT INVOKE DEFAULT IMPLEMENTATION OF super.setSelected(selected, animated: animated)
        guard selected != isCustomSelected else {
            return
        }
        
        isCustomSelected = selected
        UIView.animate(withDuration: VisualConstant.AnimationConstant.setCustomSelectedTableViewCell) {
            self.contentView.backgroundColor = selected ? .systemBlue : .systemBackground
            self.label.textColor = selected ? .white : .label
        }
        
    }
    
}
