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
    @IBOutlet private weak var reminderIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderIconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderIconWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderXMarkImageView: UIImageView!
    @IBOutlet private weak var reminderXMarkLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderXMarkTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderXMarkTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderXMarkBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderActionLabel: GeneralUILabel!
    @IBOutlet private weak var reminderActionTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderActionBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderActionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderIntervalLabel: GeneralUILabel!
    @IBOutlet private weak var reminderIntervalBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderIntervalHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var nextAlarmLabel: GeneralUILabel!
    @IBOutlet private weak var nextAlarmBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var nextAlarmHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var rightChevronLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightChevronTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var reminder: Reminder!
    
    var forDogId: Int!
    
    // MARK: - Functions
    
    // Setup function that sets up the different IBOutlet properties
    func setup(forForDogId forDogId: Int, forReminder reminder: Reminder) {
        self.forDogId = forDogId
        self.reminder = reminder
        
        //  Text and Image Configuration
        
        reminderActionLabel.text = reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true)
        
        switch reminder.reminderType {
        case .countdown:
            reminderIconImageView.image = UIImage.init(systemName: "timer")
            reminderIntervalLabel.text = reminder.countdownComponents.displayableInterval
        case .weekly:
            reminderIconImageView.image = UIImage.init(systemName: "alarm")
            reminderIntervalLabel.text = reminder.weeklyComponents.displayableInterval
        case .monthly:
            reminderIconImageView.image = UIImage.init(systemName: "calendar")
            reminderIntervalLabel.text = reminder.monthlyComponents.displayableInterval
        case .oneTime:
            reminderIconImageView.image = UIImage.init(systemName: "calendar")
            reminderIntervalLabel.text = reminder.oneTimeComponents.displayableInterval
        }
        
        // Size Ratio Configuration
        
        let sizeRatio = UserConfiguration.remindersInterfaceScale.currentScaleFactor
        
        // Reminder Action Label Configuration
        reminderActionLabel.font = reminderActionLabel.font.withSize(30.0 * sizeRatio)
        reminderActionTopConstraint.constant = 7.5 * sizeRatio
        reminderActionBottomConstraint.constant = 3.0 * sizeRatio
        reminderActionHeightConstraint.constant = 35.0 * sizeRatio
        
        // Reminder Interval Label Configuration
        
        reminderIntervalLabel.font = reminderIntervalLabel.font.withSize(15.0 * sizeRatio)
        reminderIntervalHeightConstraint.constant = 17.5 * sizeRatio
        reminderIntervalBottomConstraint.constant = 3.0 * sizeRatio
        
        // Next Alarm Label Configuration
        
        nextAlarmLabel.font = nextAlarmLabel.font.withSize(15.0 * sizeRatio)
        nextAlarmBottomConstraint.constant = 7.5 * sizeRatio
        nextAlarmHeightConstraint.constant = 17.5 * sizeRatio
        
        // Reminder Icon Configuration
        
        reminderIconLeadingConstraint.constant = 25.0 * sizeRatio
        reminderIconTrailingConstraint.constant = 12.5 * sizeRatio
        reminderIconWidthConstraint.constant = 42.5 * sizeRatio
        
        // Reminder X Mark Configuration
        
        reminderXMarkImageView.isHidden = reminder.reminderIsEnabled
        reminderXMarkLeadingConstraint.constant = 10.0 * sizeRatio
        reminderXMarkTrailingConstraint.constant = 10.0 * sizeRatio
        reminderXMarkTopConstraint.constant = 10.0 * sizeRatio
        reminderXMarkBottomConstraint.constant = 10.0 * sizeRatio
        
        // Right Chevron Configuration
        rightChevronLeadingConstraint.constant = 10.0 * sizeRatio
        rightChevronTrailingConstraint.constant = 15.0 * sizeRatio
        
        // put this reload after the sizeRatio otherwise the .font sizeRatio adjustment will change the whole text label to the same font (we want some bold and some not bold)
        reloadNextAlarmLabel()
    }
    
    func reloadNextAlarmLabel() {
        
        let nextAlarmHeaderFont = UIFont.systemFont(ofSize: nextAlarmLabel.font.pointSize, weight: .semibold)
        let nextAlarmBodyFont = UIFont.systemFont(ofSize: nextAlarmLabel.font.pointSize, weight: .regular)
        
        guard reminder.reminderIsEnabled == true, let executionDate = reminder.reminderExecutionDate else {
            nextAlarmLabel.attributedText = NSAttributedString(string: "Disabled", attributes: [NSAttributedString.Key.font: nextAlarmHeaderFont])
            return
        }
        
        if Date().distance(to: executionDate) <= 0 {
            nextAlarmLabel.attributedText = NSAttributedString(string: "No More Time Left", attributes: [NSAttributedString.Key.font: nextAlarmHeaderFont])
        }
        else if reminder.snoozeComponents.executionInterval != nil {
            // special message for snoozing time
            let timeLeftText = String.convertToReadable(fromTimeInterval: Date().distance(to: executionDate))
            
            nextAlarmLabel.font = nextAlarmBodyFont
            
            nextAlarmLabel.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font: nextAlarmBodyFont])
            
            nextAlarmLabel.attributedText = nextAlarmLabel.text?.addingFontToBeginning(text: "Finish Snoozing In: ", font: nextAlarmHeaderFont)
        }
        else {
            // regular message for regular time
            let timeLeftText = String.convertToReadable(fromTimeInterval: Date().distance(to: executionDate))
            
            nextAlarmLabel.font = nextAlarmBodyFont
            
            nextAlarmLabel.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font: nextAlarmBodyFont])
            
            nextAlarmLabel.attributedText = nextAlarmLabel.text?.addingFontToBeginning(text: "Remind In: ", font: nextAlarmHeaderFont)
        }
    }
}
