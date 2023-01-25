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
    
    @IBOutlet private weak var reminderLabel: ScaledUILabel!
    
    @IBOutlet private weak var reminderIsEnabledSwitch: UISwitch!
    
    @IBAction private func didToggleReminderIsEnabled(_ sender: Any) {
        delegate.didUpdateReminderIsEnabled(sender: Sender(origin: self, localized: self), forReminderId: reminderId, forReminderIsEnabled: reminderIsEnabledSwitch.isOn)
    }
    
    // MARK: - Properties
    
    private var reminderId: Int!
    
    weak var delegate: DogsReminderTableViewCellDelegate! = nil
    
    // MARK: - Functions
    
    func setup(forReminder reminder: Reminder) {
        reminderIsEnabledSwitch.isOn = reminder.reminderIsEnabled
        
        reminderId = reminder.reminderId
        
        reminderLabel.adjustsFontSizeToFitWidth = true
        switch reminder.reminderType {
        case .countdown:
            reminderLabel.text = reminder.countdownComponents.displayableInterval
        case .weekly:
            reminderLabel.text = reminder.weeklyComponents.displayableInterval
        case .monthly:
            reminderLabel.text = reminder.monthlyComponents.displayableInterval
        case .oneTime:
            reminderLabel.text = reminder.oneTimeComponents.displayableInterval
        }
        
        reminderLabel.attributedText = reminderLabel.text?.addingFontToBeginning(text: reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true) + " - ", font: UIFont.systemFont(ofSize: reminderLabel.font.pointSize, weight: .medium))

    }
    
}
