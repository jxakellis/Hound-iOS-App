//
//  DogsReminderTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderTableViewCellDelegate: AnyObject {
    /// The reminder switch to toggle the enable status was flipped. The reminder was updated and the server was NOT queried.
    func didUpdateReminderIsEnabled(sender: Sender, forReminderId: Int, forReminderIsEnabled: Bool)
}

final class DogsReminderTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var reminderLabel: GeneralUILabel!
    
    @IBOutlet private weak var reminderIsEnabledSwitch: UISwitch!
    
    @IBAction private func didToggleReminderIsEnabled(_ sender: Any) {
        delegate.didUpdateReminderIsEnabled(sender: Sender(origin: self, localized: self), forReminderId: reminderId, forReminderIsEnabled: reminderIsEnabledSwitch.isOn)
    }
    
    // MARK: - Properties
    
    private var reminderId: Int!
    
    weak var delegate: DogsReminderTableViewCellDelegate!
    
    // MARK: - Functions
    
    func setup(forReminder reminder: Reminder) {
        reminderIsEnabledSwitch.isOn = reminder.reminderIsEnabled
        
        reminderId = reminder.reminderId
        
        reminderLabel.shouldAdjustMinimumScaleFactor = true
        
        let precalculatedDynamicDisplayActionName = reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true)
        let precalculatedDynamicPointSize = self.reminderLabel.font.pointSize
        let precalculatedDynamicDisplayInterval = {
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
        
        reminderLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            
            let message = NSMutableAttributedString(
                string: precalculatedDynamicDisplayActionName + " - ",
                attributes: [.font: UIFont.systemFont(ofSize: precalculatedDynamicPointSize, weight: .medium)]
            )
            
            message.append(NSAttributedString(
                string: precalculatedDynamicDisplayInterval,
                attributes: [.font: UIFont.systemFont(ofSize: precalculatedDynamicPointSize, weight: .regular)]))
            
            return message
        }

    }
    
}
