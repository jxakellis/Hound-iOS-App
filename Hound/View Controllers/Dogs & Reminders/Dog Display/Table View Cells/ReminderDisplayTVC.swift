//
//  DogsMainScreenTableViewCellReminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsReminderDisplayTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var reminderIconImageView: UIImageView!
    @IBOutlet private weak var reminderIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderIconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderIconWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderXMarkImageView: UIImageView!
    @IBOutlet private weak var reminderXMarkLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderXMarkTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderXMarkTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderXMarkBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderActionLabel: ScaledUILabel!
    @IBOutlet private weak var reminderActionTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderActionBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderActionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reminderIntervalLabel: ScaledUILabel!
    @IBOutlet private weak var reminderIntervalBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reminderIntervalHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var nextAlarmLabel: ScaledUILabel!
    @IBOutlet private weak var nextAlarmBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var nextAlarmHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var rightChevronLeadingConstraint: UIView!
    @IBOutlet private weak var rightChevronTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightChevronWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var reminder: Reminder!
    
    var forDogId: Int!
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Setup
    
    // Setup function that sets up the different IBOutlet properties
    func setup(forForDogId forDogId: Int, forReminder reminder: Reminder) {
        self.forDogId = forDogId
        self.reminder = reminder
        
        //  Text and Image Configuration
        
        reminderActionLabel.text = reminder.reminderAction.displayActionName(reminderCustomActionName: reminder.reminderCustomActionName, isShowingAbreviatedCustomActionName: true)
        
        switch reminder.reminderType {
        case .countdown:
            reminderIconImageView.image = UIImage.init(systemName: "timer")
            reminderIntervalLabel.text = ("Every \(String.convertToReadable(fromTimeInterval: reminder.countdownComponents.executionInterval))")
        case .weekly:
            reminderIconImageView.image = UIImage.init(systemName: "alarm")
            reminderIntervalLabel.text = ("\(String.convertToReadable(fromUTCHour: reminder.weeklyComponents.UTCHour, fromUTCMinute: reminder.weeklyComponents.UTCMinute))")
            
            // weekdays
            if reminder.weeklyComponents.weekdays == [1, 2, 3, 4, 5, 6, 7] {
                reminderIntervalLabel.text?.append(" Everyday")
            }
            else if reminder.weeklyComponents.weekdays == [1, 7] {
                reminderIntervalLabel.text?.append(" on Weekends")
            }
            else if reminder.weeklyComponents.weekdays == [2, 3, 4, 5, 6] {
                reminderIntervalLabel.text?.append(" on Weekdays")
            }
            else {
                reminderIntervalLabel.text?.append(" on")
                let shouldAbreviateWeekday = reminder.weeklyComponents.weekdays.count > 1
                for weekdayInt in reminder.weeklyComponents.weekdays {
                    switch weekdayInt {
                    case 1:
                        reminderIntervalLabel.text?.append(shouldAbreviateWeekday ? " Su," : " Sunday")
                    case 2:
                        reminderIntervalLabel.text?.append(shouldAbreviateWeekday ? " M," : " Monday")
                    case 3:
                        reminderIntervalLabel.text?.append(shouldAbreviateWeekday ? " Tu," : " Tuesday")
                    case 4:
                        reminderIntervalLabel.text?.append(shouldAbreviateWeekday ? " W," : " Wednesday")
                    case 5:
                        reminderIntervalLabel.text?.append(shouldAbreviateWeekday ? " Th," : " Thursday")
                    case 6:
                        reminderIntervalLabel.text?.append(shouldAbreviateWeekday ? " F," : " Friday")
                    case 7:
                        reminderIntervalLabel.text?.append(shouldAbreviateWeekday ? " Sa," : " Saturday")
                    default:
                        reminderIntervalLabel.text?.append(VisualConstant.TextConstant.unknownText)
                    }
                }
                // checks if extra comma, then removes
                if reminderIntervalLabel.text?.last == ","{
                    reminderIntervalLabel.text?.removeLast()
                }
            }
        case .monthly:
            reminderIconImageView.image = UIImage.init(systemName: "calendar")
            reminderIntervalLabel.text = ("\(String.convertToReadable(fromUTCHour: reminder.monthlyComponents.UTCHour, fromUTCMinute: reminder.monthlyComponents.UTCMinute))")
            
            // day of month
            let monthlyUTCDay: Int = reminder.monthlyComponents.UTCDay
            reminderIntervalLabel.text?.append(" Every Month on \(monthlyUTCDay)")
            
            reminderIntervalLabel.text?.append(String.daySuffix(day: monthlyUTCDay))
        case .oneTime:
            reminderIconImageView.image = UIImage.init(systemName: "calendar")
            reminderIntervalLabel.text = String.convertToReadable(fromDate: reminder.oneTimeComponents.oneTimeDate)
        }
        
        // Size Ratio Configuration
        
        let sizeRatio = UserConfiguration.remindersInterfaceScale.currentScaleFactor
        
        // Reminder Action Label Configuration
        reminderActionLabel.font = reminderActionLabel.font.withSize(25.0 * sizeRatio)
        reminderActionTopConstraint.constant = 7.5 * sizeRatio
        reminderActionBottomConstraint.constant = 2.5 * sizeRatio
        reminderActionHeightConstraint.constant = 30.0 * sizeRatio
        
        // Reminder Interval Label Configuration
        
        reminderIntervalLabel.font = reminderIntervalLabel.font.withSize(12.5 * sizeRatio)
        reminderIntervalHeightConstraint.constant = 15.0 * sizeRatio
        reminderIntervalBottomConstraint.constant = 2.5 * sizeRatio
        
        // Next Alarm Label Configuration
        
        nextAlarmLabel.font = nextAlarmLabel.font.withSize(12.5 * sizeRatio)
        nextAlarmBottomConstraint.constant = 7.5 * sizeRatio
        nextAlarmHeightConstraint.constant = 15.0 * sizeRatio
        
        // Reminder Icon Configuration
        
        reminderIconImageView.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        reminderIconLeadingConstraint.constant = 20.0 * sizeRatio
        reminderIconTrailingConstraint.constant = 10.0 * sizeRatio
        reminderIconWidthConstraint.constant = 35.0 * sizeRatio
        
        // Reminder X Mark Configuration
        
        reminderXMarkImageView.isHidden = reminder.reminderIsEnabled
        reminderXMarkLeadingConstraint.constant = 7.5 * sizeRatio
        reminderXMarkTrailingConstraint.constant = 7.5 * sizeRatio
        reminderXMarkTopConstraint.constant = 7.5 * sizeRatio
        reminderXMarkBottomConstraint.constant = 7.5 * sizeRatio
        
        // put this reload after the sizeRatio otherwise the .font sizeRatio adjustment will change the whole text label to the same font (we want some bold and some not bold)
        reloadNextAlarmText()
    }
    
    func reloadNextAlarmText() {
        
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
