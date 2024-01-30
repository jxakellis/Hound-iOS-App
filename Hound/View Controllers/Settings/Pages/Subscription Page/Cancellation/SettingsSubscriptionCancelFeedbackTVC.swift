//
//  SettingsSubscriptionCancelFeedbackTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/28/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsSubscriptionCancelFeedbackTableViewCellDelegate: AnyObject {
    func didSetCustomIsSelected(forCell: SettingsSubscriptionCancelFeedbackTableViewCell, forIsCustomSelected: Bool)
}

final class SettingsSubscriptionCancelFeedbackTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private weak var containerView: UIView!

    @IBOutlet private weak var cancellationReasonLabel: GeneralUILabel!
    @IBOutlet private weak var checkmarkImageView: UIImageView!

    // MARK: - Properties

    /// The cancellation reason this cell is displaying
    private(set) var cancellationReason: SubscriptionCancellationReason?

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    private var isCustomSelected: Bool = false

    private weak var delegate: SettingsSubscriptionCancelFeedbackTableViewCellDelegate?

    // MARK: - Functions

    func setup(forDelegate: SettingsSubscriptionCancelFeedbackTableViewCellDelegate, forCancellationReason: SubscriptionCancellationReason, forIsCustomSelected: Bool) {
        self.delegate = forDelegate
        self.cancellationReason = forCancellationReason

        containerView.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius
        containerView.layer.cornerCurve = .continuous

        setCustomSelectedTableViewCell(forSelected: forIsCustomSelected, isAnimated: false)
    }

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelectedTableViewCell(forSelected: Bool, isAnimated: Bool) {
        isCustomSelected = forSelected

        delegate?.didSetCustomIsSelected(forCell: self, forIsCustomSelected: isCustomSelected)

        UIView.animate(withDuration: isAnimated ? VisualConstant.AnimationConstant.toggleSelectUIElement : 0.0) {
            self.checkmarkImageView.isHidden = !self.isCustomSelected

            self.containerView.layer.borderColor = self.isCustomSelected ? UIColor.systemGreen.cgColor : UIColor.label.cgColor
            self.containerView.layer.borderWidth = self.isCustomSelected ? 4.0 : 2.0

            self.setupCancellationLabel()
        }
    }

    /// Attempts to set the attributedText for cancellationReasonLabel given the cancellationReason and isCustomSelected
    private func setupCancellationLabel() {
        guard let cancellationReason = cancellationReason else {
            cancellationReasonLabel.text = VisualConstant.TextConstant.unknownText
            return
        }

        // If the cell isn't selected, all of the text is the tertiary label color
        let cancellationReasonTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .medium),
            .foregroundColor: UIColor.label
        ]
        
        cancellationReasonLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            // "" -> "6 months - $59.99"
            let message: NSMutableAttributedString = NSMutableAttributedString(
                string: cancellationReason.readableValue,
                attributes: cancellationReasonTextAttributes)

            return message
        }
    }

}
