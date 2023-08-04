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

    @IBOutlet private(set) weak var containerView: UIView! // swiftlint:disable:this private_outlet

    @IBOutlet private weak var displayFullNameLabel: GeneralUILabel!

    @IBOutlet private weak var rightChevronImageView: GeneralUIImageView!
    @IBOutlet private weak var rightChevronLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightChevronTrailingConstraint: NSLayoutConstraint!

    // MARK: - Functions

    func setup(forDisplayFullName displayFullName: String) {
        displayFullNameLabel.text = displayFullName

        let isUserFamilyHead = FamilyInformation.isUserFamilyHead
        // if the user is not the family head, that means the cell should not be selectable nor should we show the chevron that indicates selectability
        isUserInteractionEnabled = isUserFamilyHead
        rightChevronImageView.isHidden = !isUserFamilyHead

        rightChevronLeadingConstraint.constant = isUserFamilyHead ? 5.0 : 0.0
        rightChevronTrailingConstraint.constant = isUserFamilyHead ? 7.5 : 0.0
    }

}
