//
//  DogsReminderWeeklyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderWeeklyViewControllerDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsReminderWeeklyViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private var interDayOfWeekConstraints: [NSLayoutConstraint]!
    
    @IBOutlet private weak var sundayButton: ScaledImageWithBackgroundUIButton!
    @IBOutlet private weak var mondayButton: ScaledImageWithBackgroundUIButton!
    @IBOutlet private weak var tuesdayButton: ScaledImageWithBackgroundUIButton!
    @IBOutlet private weak var wednesdayButton: ScaledImageWithBackgroundUIButton!
    @IBOutlet private weak var thursdayButton: ScaledImageWithBackgroundUIButton!
    @IBOutlet private weak var fridayButton: ScaledImageWithBackgroundUIButton!
    @IBOutlet private weak var saturdayButton: ScaledImageWithBackgroundUIButton!
    
    @IBAction private func didToggleWeekdayButton(_ sender: Any) {
        delegate.willDismissKeyboard()
        
        guard let senderButton = sender as? ScaledImageWithBackgroundUIButton else {
            return
        }
        var targetColor: UIColor!
        
        if senderButton.tag == VisualConstant.ViewTagConstant.weekdayEnabled {
            targetColor = UIColor.systemGray4
            senderButton.tag = VisualConstant.ViewTagConstant.weekdayDisabled
        }
        else {
            targetColor = UIColor.systemBlue
            senderButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
        }
        
        senderButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: VisualConstant.AnimationConstant.toggleWeekdayButton) {
            senderButton.tintColor = targetColor
        } completion: { (_) in
            senderButton.isUserInteractionEnabled = true
        }
        
    }
    
    @IBOutlet private weak var timeOfDayDatePicker: UIDatePicker!
    
    @IBAction private func didUpdateTimeOfDay(_ sender: Any) {
        delegate.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    weak var delegate: DogsReminderWeeklyViewControllerDelegate!
    
    /// Converts enabled buttons to an array of day of weeks according to CalendarComponents.weekdays, 1 being sunday and 7 being saturday
    var weekdays: [Int]? {
        var days: [Int] = []
        let dayOfWeekButtons = [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton]
        
        for dayOfWeekIndex in 0..<dayOfWeekButtons.count where dayOfWeekButtons[dayOfWeekIndex]?.tag == VisualConstant.ViewTagConstant.weekdayEnabled {
            days.append(dayOfWeekIndex + 1)
        }
        
        if days.isEmpty == true {
            return nil
        }
        else {
            return days
        }
        
    }
    
    var passedTimeOfDay: Date?
    
    var passedWeekDays: [Int]? = [1, 2, 3, 4, 5, 6, 7]
    
    var initalValuesChanged: Bool {
        if weekdays != passedWeekDays {
            return true
        }
        else if timeOfDayDate != passedTimeOfDay {
            return true
        }
        return false
    }
    
    var timeOfDayDate: Date {
        get {
            return timeOfDayDatePicker.date
        }
        set (date) {
            timeOfDayDatePicker.date = date
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWeekdays()
        
        timeOfDayDatePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        
        // keep duplicate as without it the user can see the .asyncafter visual scroll, but this duplicate stops a value changed not being called on first value change bug
        if let passedTimeOfDay = passedTimeOfDay {
            timeOfDayDate = passedTimeOfDay
        }
        else {
            self.timeOfDayDate = Date.roundDate(targetDate: Date(), roundingInterval: TimeInterval(60 * timeOfDayDatePicker.minuteInterval), roundingMethod: .up)
            passedTimeOfDay = timeOfDayDate
        }
        
        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.timeOfDayDate = self.timeOfDayDate
        }
    }
    
    /// Certain views must be adapted in viewDidLayoutSubviews as properties (such as frames) are not updated until the subviews are laid out (before that point in time they hold the placeholder storyboard value). However, viewDidLayoutSubviews is called multiple times, therefore we must lock it to executing certain code once with this variable. viewDidLayoutSubviews is the superior choice to viewDidAppear as viewDidAppear has the downside of performing these changes once the user can see the view
    private var didSetupCustomSubviews: Bool = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // DogsReminderWeeklyViewController IS EMBEDDED inside other view controllers. This means IT DOES NOT have any safe area insets. Only the view controllers that are presented onto MainTabBarViewController or are in the navigation stack have safe area insets. This is because those views take up the whole screen, so they MUST consider the phone's safe area (i.e. top bar with time, wifi, and battery and bottom bar).
        
        guard didSetupCustomSubviews == false else {
            return
        }
        
        didSetupCustomSubviews = true
        
        for constraint in interDayOfWeekConstraints {
            // the distance between week day buttons should be 8 points on a 414 point screen, so this adjusts that ratio to fit any width of screen
            constraint.constant = (8.0 / 414.0) * self.view.safeAreaLayoutGuide.layoutFrame.width
        }
        
    }
    
    // MARK: - Functions
    
    private func setupWeekdays() {
        disableAllWeekdays()
        enableSelectedWeekDays()
        
        func disableAllWeekdays() {
            let dayOfWeekButtons = [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton]
            
            for dayOfWeekButton in dayOfWeekButtons {
                guard let dayOfWeekButton = dayOfWeekButton else {
                    continue
                }
                dayOfWeekButton.tintColor = UIColor.systemGray4
                dayOfWeekButton.tag = VisualConstant.ViewTagConstant.weekdayDisabled
            }
        }
        
        func enableSelectedWeekDays() {
            guard let passedWeekDays = passedWeekDays else {
                return
            }
            
            for dayOfWeek in passedWeekDays {
                switch dayOfWeek {
                case 1:
                    sundayButton.tintColor = .systemBlue
                    sundayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
                case 2:
                    mondayButton.tintColor = .systemBlue
                    mondayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
                case 3:
                    tuesdayButton.tintColor = .systemBlue
                    tuesdayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
                case 4:
                    wednesdayButton.tintColor = .systemBlue
                    wednesdayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
                case 5:
                    thursdayButton.tintColor = .systemBlue
                    thursdayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
                case 6:
                    fridayButton.tintColor = .systemBlue
                    fridayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
                case 7:
                    saturdayButton.tintColor = .systemBlue
                    saturdayButton.tag = VisualConstant.ViewTagConstant.weekdayEnabled
                default:
                    break
                }
            }
        }
    }
    
}
