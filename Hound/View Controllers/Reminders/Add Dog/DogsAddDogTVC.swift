//
//  DogsAddDogTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogTableViewCellDelegate: AnyObject {
    /// The reminder switch to toggle the enable status was flipped. The reminder was updated and the server was NOT queried.
    func didUpdateReminderIsEnabled(sender: Sender, forReminderId: Int, forReminderIsEnabled: Bool)
}

final class DogsAddDogTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private(set) weak var containerView: UIView! // swiftlint:disable:this private_outlet

    @IBOutlet private weak var reminderActionLabel: GeneralUILabel!

    @IBOutlet private weak var reminderDisplayableIntervalLabel: GeneralUILabel!

    @IBOutlet private weak var reminderIsEnabledSwitch: UISwitch!

    @IBAction private func didToggleReminderIsEnabled(_ sender: Any) {
        guard let reminderId = reminderId else {
            return
        }

        delegate.didUpdateReminderIsEnabled(sender: Sender(origin: self, localized: self), forReminderId: reminderId, forReminderIsEnabled: reminderIsEnabledSwitch.isOn)
    }

    // MARK: - Properties

    private var reminderId: Int?

    weak var delegate: DogsAddDogTableViewCellDelegate!

    // MARK: - Functions

    func setup(forReminder reminder: Reminder) {
        reminderIsEnabledSwitch.isOn = reminder.reminderIsEnabled

        reminderId = reminder.reminderId

        let precalculatedDynamicReminderActionName = reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true)
        let precalculatedDynamicReminderActionFont = self.reminderActionLabel.font ?? UIFont()

        let precalculatedDynamicReminderDisplayInterval = {
            switch reminder.reminderType {
            case .countdown:
                return reminder.countdownComponents.displayableInterval
            case .weekly:
                return reminder.weeklyComponents.displayableInterval
            case .monthly:
                return reminder.monthlyComponents.displayableInterval
            case .oneTime:
                return reminder.oneTimeComponents.displayableInterval
            }
        }()
        let precalculatedDynamicReminderDisplayIntervalFont = self.reminderDisplayableIntervalLabel.font ?? UIFont()

        reminderActionLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode

            return NSMutableAttributedString(
                string: precalculatedDynamicReminderActionName,
                attributes: [.font: precalculatedDynamicReminderActionFont]
            )
        }

        reminderDisplayableIntervalLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode

            return NSAttributedString(
                string: precalculatedDynamicReminderDisplayInterval,
                attributes: [.font: precalculatedDynamicReminderDisplayIntervalFont])
        }

    }

}
