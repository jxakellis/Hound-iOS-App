//
//  DogsMainScreenTableViewCellReminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsReminderTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private(set) weak var containerView: UIView! // swiftlint:disable:this private_outlet
    
    @IBOutlet private weak var reminderActionIconLabel: GeneralUILabel!
    
    @IBOutlet private weak var reminderActionWithoutIconLabel: GeneralUILabel!
    
    @IBOutlet private weak var reminderRecurranceLabel: GeneralUILabel!
    
    @IBOutlet private weak var reminderTimeOfDayLabel: GeneralUILabel!
    private var reminderTimeOfDayBottomConstraintConstant: CGFloat?
    @IBOutlet private weak var reminderTimeOfDayBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderNextAlarmLabel: GeneralUILabel!
    private var reminderNextAlarmHeightConstraintConstant: CGFloat?
    @IBOutlet private weak var reminderNextAlarmHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var rightChevronImageView: GeneralUIImageView!
    
    // MARK: - Properties
    
    var reminder: Reminder?
    
    var dogId: Int?
    
    private let reminderEnabledElementAlpha: CGFloat = 1.0
    private let reminderDisabledElementAlpha: CGFloat = 0.4
    
    // MARK: - Functions
    
    // Setup function that sets up the different IBOutlet properties
    func setup(forDogUUID: UUID, forReminder: Reminder) {
        self.dogId = forDogUUID
        self.reminder = forReminder
        
        // Cell can be re-used by the tableView, so the constraintConstants won't be nil in that case and their original values saved
        reminderTimeOfDayBottomConstraintConstant = reminderTimeOfDayBottomConstraintConstant ?? reminderTimeOfDayBottomConstraint.constant
        reminderNextAlarmHeightConstraintConstant = reminderNextAlarmHeightConstraintConstant ?? reminderNextAlarmHeightConstraint.constant
        
        // MARK: reminderActionIcon
        reminderActionIconLabel.text = forReminder.reminderAction.readableEmoji
        reminderActionIconLabel.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        
        // MARK: reminderActionWithoutIconLabel
        reminderActionWithoutIconLabel.text = forReminder.reminderAction.fullReadableName(reminderCustomActionName: forReminder.reminderCustomActionName, includeMatchingEmoji: false)
        reminderActionWithoutIconLabel.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        
        // MARK: reminderRecurranceLabel
        reminderRecurranceLabel.text = {
            switch forReminder.reminderType {
            case .countdown:
                return forReminder.countdownComponents.readableRecurranceInterval
            case .weekly:
                return forReminder.weeklyComponents.readableRecurranceInterval
            case .monthly:
                return forReminder.monthlyComponents.readableRecurranceInterval
            case .oneTime:
                return forReminder.oneTimeComponents.readableRecurranceInterval
            }
        }()
        reminderRecurranceLabel.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        
        // MARK: reminderTimeOfDayLabel
        reminderTimeOfDayLabel.text = {
            switch forReminder.reminderType {
            case .countdown:
                return forReminder.countdownComponents.readableTimeOfDayInterval
            case .weekly:
                return forReminder.weeklyComponents.readableTimeOfDayInterval
            case .monthly:
                return forReminder.monthlyComponents.readableTimeOfDayInterval
            case .oneTime:
                return forReminder.oneTimeComponents.readableTimeOfDayInterval
            }
        }()
        reminderTimeOfDayLabel.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        
        // MARK: reminderNextAlarmLabel
        reloadReminderNextAlarmLabel()
        
        // MARK: rightChevronImageView
        rightChevronImageView.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
    }
    
    func reloadReminderNextAlarmLabel() {
        guard let reminder = reminder else {
            return
        }
        
        guard reminder.reminderIsEnabled == true, let executionDate = reminder.reminderExecutionDate else {
            // The reminder is disabled, therefore don't show the next alarm label or padding for it as there is nothing to display
            reminderNextAlarmLabel.isHidden = true
            reminderTimeOfDayBottomConstraint.constant = 0.0
            reminderNextAlarmHeightConstraint.constant = 0.0
            return
        }
        
        // Reminder is enabled, therefore show the next alarm label
        reminderNextAlarmLabel.isHidden = false
        reminderTimeOfDayBottomConstraint.constant = reminderTimeOfDayBottomConstraintConstant ?? reminderTimeOfDayBottomConstraint.constant
        reminderNextAlarmHeightConstraint.constant = reminderNextAlarmHeightConstraintConstant ?? reminderNextAlarmHeightConstraint.constant
        
        let nextAlarmHeaderFont = UIFont.systemFont(ofSize: reminderNextAlarmLabel.font.pointSize, weight: .semibold)
        let nextAlarmBodyFont = UIFont.systemFont(ofSize: reminderNextAlarmLabel.font.pointSize, weight: .regular)
        
        guard Date().distance(to: executionDate) > 0 else {
            reminderNextAlarmLabel.attributedTextClosure = {
                // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
                
                // Add extra spaces at the start and end so the text visually sits properly with its alternative background color and bordered edges
                return NSAttributedString(string: "  No More Time Left  ", attributes: [.font: nextAlarmHeaderFont])
            }
            return
        }
        
        let precalculatedDynamicIsSnoozing = reminder.snoozeComponents.executionInterval != nil
        let precalculatedDynamicText = Date().distance(to: executionDate).readable(capitalizeWords: true, abreviateWords: false)
        
        reminderNextAlarmLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            
            // Add extra spaces at the start and end so the text visually sits properly with its alternative background color and bordered edges
            let message = NSMutableAttributedString(
                string: precalculatedDynamicIsSnoozing ? "  Finish Snoozing In: " : "  Remind In: ",
                attributes: [.font: nextAlarmHeaderFont]
            )
            
            // Add extra spaces at the start and end so the text visually sits properly with its alternative background color and bordered edges
            message.append(NSAttributedString(string: "\(precalculatedDynamicText)  ", attributes: [.font: nextAlarmBodyFont]))
            
            return message
            
        }
    }
}
