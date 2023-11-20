//
//  DogsMainScreenTableViewCellReminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsReminderDisplayTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private(set) weak var containerView: UIView! // swiftlint:disable:this private_outlet

    @IBOutlet private weak var reminderIconImageView: UIImageView!

    @IBOutlet private weak var reminderXMarkImageView: UIImageView!

    @IBOutlet private weak var reminderActionLabel: GeneralUILabel!

    @IBOutlet private weak var reminderIntervalLabel: GeneralUILabel!

    @IBOutlet private weak var nextAlarmLabel: GeneralUILabel!

    // MARK: - Properties

    var reminder: Reminder?

    var dogId: Int?

    // MARK: - Functions

    // Setup function that sets up the different IBOutlet properties
    func setup(forDogId: Int, forReminder: Reminder) {
        self.dogId = forDogId
        self.reminder = forReminder

        //  Text and Image Configuration

        reminderActionLabel.text = forReminder.reminderAction.displayActionName(reminderCustomActionName: forReminder.reminderCustomActionName)

        switch forReminder.reminderType {
        case .countdown:
            reminderIconImageView.image = UIImage.init(systemName: "timer")
            reminderIntervalLabel.text = forReminder.countdownComponents.displayableInterval
        case .weekly:
            reminderIconImageView.image = UIImage.init(systemName: "alarm")
            reminderIntervalLabel.text = forReminder.weeklyComponents.displayableInterval
        case .monthly:
            reminderIconImageView.image = UIImage.init(systemName: "calendar")
            reminderIntervalLabel.text = forReminder.monthlyComponents.displayableInterval
        case .oneTime:
            reminderIconImageView.image = UIImage.init(systemName: "calendar")
            reminderIntervalLabel.text = forReminder.oneTimeComponents.displayableInterval
        }
        
        reminderXMarkImageView.isHidden = forReminder.reminderIsEnabled

        reloadNextAlarmLabel()
    }

    func reloadNextAlarmLabel() {
        guard let reminder = reminder else {
            return
        }
        
        let nextAlarmHeaderFont = UIFont.systemFont(ofSize: nextAlarmLabel.font.pointSize, weight: .semibold)
        let nextAlarmBodyFont = UIFont.systemFont(ofSize: nextAlarmLabel.font.pointSize, weight: .regular)

        guard reminder.reminderIsEnabled == true, let executionDate = reminder.reminderExecutionDate else {
            nextAlarmLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
                return NSAttributedString(string: "Disabled", attributes: [.font: nextAlarmHeaderFont])
            }
            return
        }

        if Date().distance(to: executionDate) <= 0 {
            nextAlarmLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
                return NSAttributedString(string: "No More Time Left", attributes: [.font: nextAlarmHeaderFont])
            }
        }
        else {
            let precalculatedDynamicIsSnoozing = reminder.snoozeComponents.executionInterval != nil
            let precalculatedDynamicText = Date().distance(to: executionDate).readable(capitalizeWords: true, abreviateWords: false)

            nextAlarmLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
                let message = NSMutableAttributedString(
                    string: precalculatedDynamicIsSnoozing ? "Finish Snoozing In: " : "Remind In: ",
                    attributes: [.font: nextAlarmHeaderFont]
                )

                message.append(NSAttributedString(string: precalculatedDynamicText, attributes: [.font: nextAlarmBodyFont]))

                return message
            }
        }
    }
}
