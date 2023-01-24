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
        reminderLabel.adjustsFontSizeToFitWidth = true
        
        reminderId = reminder.reminderId
        
        reminderLabel.text = ""
        
        if reminder.reminderType == .oneTime {
            setupOneTimeReminder()
        }
        else if reminder.reminderType == .countdown {
            setupCountdownReminder()
        }
        else if reminder.reminderType == .monthly {
            setupMonthlyReminder()
        }
        else if reminder.reminderType == .weekly {
            setupWeeklyReminder()
        }
        
        reminderLabel.attributedText = reminderLabel.text?.addingFontToBeginning(text: reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true) + " -", font: UIFont.systemFont(ofSize: reminderLabel.font.pointSize, weight: .medium))
        
        reminderIsEnabledSwitch.isOn = reminder.reminderIsEnabled
        
        func setupOneTimeReminder() {
            self.reminderLabel.text? = " \(String.convertToReadable(fromDate: reminder.oneTimeComponents.oneTimeDate))"
        }
        
        func setupCountdownReminder() {
            self.reminderLabel.text?.append(" Every \(String.convertToReadable(fromTimeInterval: reminder.countdownComponents.executionInterval))")
        }
        
        func setupMonthlyReminder() {
            let monthlyUTCDay = reminder.monthlyComponents.UTCDay
            reminderLabel.text?.append(" Every Month on \(monthlyUTCDay)")
            
            reminderLabel.text?.append(monthlyUTCDay.daySuffix())
        }
        
        func setupWeeklyReminder() {
            reminderLabel.text?.append(" \(String.convertToReadable(fromUTCHour: reminder.weeklyComponents.UTCHour, fromUTCMinute: reminder.weeklyComponents.UTCMinute))")
            
            // weekdays
            if reminder.weeklyComponents.weekdays == [1, 2, 3, 4, 5, 6, 7] {
                reminderLabel.text?.append(" Everyday")
            }
            else if reminder.weeklyComponents.weekdays == [1, 7] {
                reminderLabel.text?.append(" on Weekends")
            }
            else if reminder.weeklyComponents.weekdays == [2, 3, 4, 5, 6] {
                reminderLabel.text?.append(" on Weekdays")
            }
            else {
                reminderLabel.text?.append(" on")
                let shouldAbreviateWeekday = reminder.weeklyComponents.weekdays.count > 1
                for weekdayInt in reminder.weeklyComponents.weekdays {
                    switch weekdayInt {
                    case 1:
                        reminderLabel.text?.append(shouldAbreviateWeekday ? " Su," : " Sunday")
                    case 2:
                        reminderLabel.text?.append(shouldAbreviateWeekday ? " M," : " Monday")
                    case 3:
                        reminderLabel.text?.append(shouldAbreviateWeekday ? " Tu," : " Tuesday")
                    case 4:
                        reminderLabel.text?.append(shouldAbreviateWeekday ? " W," : " Wednesday")
                    case 5:
                        reminderLabel.text?.append(shouldAbreviateWeekday ? " Th," : " Thursday")
                    case 6:
                        reminderLabel.text?.append(shouldAbreviateWeekday ? " F," : " Friday")
                    case 7:
                        reminderLabel.text?.append(shouldAbreviateWeekday ? " Sa," : " Saturday")
                    default:
                        reminderLabel.text?.append(VisualConstant.TextConstant.unknownText)
                    }
                }
                // checks if extra comma, then removes
                if reminderLabel.text?.last == ","{
                    reminderLabel.text?.removeLast()
                }
            }
        }
        
    }
    
}
