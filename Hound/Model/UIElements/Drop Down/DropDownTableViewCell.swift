//
//  DropDownParentDogTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/2/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

// NOT final class
class DropDownTableViewCell: UITableViewCell {
    
    // MARK: IB
    
    @IBOutlet weak var label: ScaledUILabel! // swiftlint:disable:this private_outlet
    
    @IBOutlet private weak var leading: NSLayoutConstraint!
    
    @IBOutlet private weak var trailing: NSLayoutConstraint!
    
    // MARK: Properties
    
    /// isSelected is used and modified by the system when a user physically clicks on a cell. If we use isSelected, this will mess up our tracking. We need a variable that tracks whether or not the cell is selected/highlighted in the drop down and that does not change. Therefore, we make our own isSelected property
    var isSelectedInDropDown: Bool = false
    
    // MARK: Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Functions
    
    func adjustLeadingTrailing(newConstant: CGFloat) {
        leading.constant = newConstant
        trailing.constant = newConstant
    }
    
    func willToggleDropDownSelection(forSelected selected: Bool) {
        guard selected != isSelectedInDropDown else {
            return
        }
        
        isSelectedInDropDown = selected
        UIView.animate(withDuration: VisualConstant.AnimationConstant.willToggleDropDownSelection) {
            self.contentView.backgroundColor = selected ? .systemBlue : .systemBackground
            self.label.textColor = selected ? .white : .label
        }
        
    }
    
}
