//
//  DogsAddDogDisplayReminderTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogDisplayReminderTableViewCellDelegate: AnyObject {
    /// The reminder switch to toggle the enable status was flipped. The reminder was updated and the server was NOT queried.
    func didUpdateReminderIsEnabled(sender: Sender, forReminderUUID: UUID, forReminderIsEnabled: Bool)
}

final class DogsAddDogDisplayReminderTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private(set) weak var containerView: UIView! // swiftlint:disable:this private_outlet

    @IBOutlet private weak var reminderActionLabel: GeneralUILabel!
    @IBOutlet private weak var reminderActionTopConstaint: NSLayoutConstraint!
    @IBOutlet private weak var reminderActionHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderActionBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderDisplayableIntervalLabel: GeneralUILabel!
    @IBOutlet private weak var reminderDisplayableIntervalHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderDisplayableIntervalBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderIsEnabledSwitch: UISwitch!

    @IBAction private func didToggleReminderIsEnabled(_ sender: Any) {
        guard let reminderUUID = reminderUUID else {
            return
        }

        delegate.didUpdateReminderIsEnabled(sender: Sender(origin: self, localized: self), forReminderUUID: reminderUUID, forReminderIsEnabled: reminderIsEnabledSwitch.isOn)
    }

    // MARK: - Properties

    private var reminderUUID: UUID?

    weak var delegate: DogsAddDogDisplayReminderTableViewCellDelegate!

    // MARK: - Functions

    func setup(forReminder: Reminder) {
        reminderIsEnabledSwitch.isOn = forReminder.reminderIsEnabled

        reminderUUID = forReminder.reminderUUID

        let precalculatedReminderActionName = forReminder.reminderAction.fullReadableName(reminderCustomActionName: forReminder.reminderCustomActionName)
        let precalculatedReminderActionFont = self.reminderActionLabel.font ?? UIFont()

        let precalculatedReminderDisplayInterval = {
            switch forReminder.reminderType {
            case .countdown:
                return forReminder.countdownComponents.readableInterval
            case .weekly:
                return forReminder.weeklyComponents.readableInterval
            case .monthly:
                return forReminder.monthlyComponents.readableInterval
            case .oneTime:
                return forReminder.oneTimeComponents.readableInterval
            }
        }()
        let precalculatedReminderDisplayIntervalFont = self.reminderDisplayableIntervalLabel.font ?? UIFont()

        reminderActionLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode

            return NSMutableAttributedString(
                string: precalculatedReminderActionName,
                attributes: [.font: precalculatedReminderActionFont]
            )
        }

        reminderDisplayableIntervalLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode

            return NSAttributedString(
                string: precalculatedReminderDisplayInterval,
                attributes: [.font: precalculatedReminderDisplayIntervalFont])
        }

    }

}
