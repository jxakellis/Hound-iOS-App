//
//  SettingsNotificationsCatagoriesAccountTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotificationsCatagoriesAccountTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private weak var descriptionLabel: GeneralUILabel!

    // MARK: - Main

    override func awakeFromNib() {
        super.awakeFromNib()

        let precalculatedDynamicTextColor = descriptionLabel.textColor
        descriptionLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            let message = NSMutableAttributedString(
                string: "Receive notifications about your account. ",
                attributes: [
                    .font: VisualConstant.FontConstant.secondaryLabelColorFeatureDescriptionLabel,
                    .foregroundColor: precalculatedDynamicTextColor as Any
                ]
            )

            message.append(NSAttributedString(
                string: "This category cannot be turned off.",
                attributes: [
                    .font: VisualConstant.FontConstant.emphasizedSecondaryLabelColorFeatureDescriptionLabel,
                    .foregroundColor: precalculatedDynamicTextColor as Any
                ])
            )

            message.append(NSAttributedString(
                string: " Examples include: getting kicked from your Hound family, accidentally terminating Hound while Loud Alarms is enabled.",
                attributes: [
                    .font: VisualConstant.FontConstant.secondaryLabelColorFeatureDescriptionLabel,
                    .foregroundColor: precalculatedDynamicTextColor as Any
                ])
            )

            return message
        }
    }
}
