//
//  DogsReminderWeeklyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderWeeklyViewControllerDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsReminderWeeklyViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private var interDayOfWeekConstraints: [NSLayoutConstraint]!
    
    @IBOutlet private weak var sundayButton: ScaledUIButton!
    @IBOutlet private weak var mondayButton: ScaledUIButton!
    @IBOutlet private weak var tuesdayButton: ScaledUIButton!
    @IBOutlet private weak var wednesdayButton: ScaledUIButton!
    @IBOutlet private weak var thursdayButton: ScaledUIButton!
    @IBOutlet private weak var fridayButton: ScaledUIButton!
    @IBOutlet private weak var saturdayButton: ScaledUIButton!
    
    @IBOutlet private var dayOfWeekBackgrounds: [ScaledUIButton]!
    
    @IBAction private func didToggleWeekdayButton(_ sender: Any) {
        delegate.willDismissKeyboard()
        
        guard let senderButton = sender as? ScaledUIButton else {
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
        UIView.animate(withDuration: VisualConstant.AnimationConstant.weekdayButton) {
            senderButton.tintColor = targetColor
        } completion: { (_) in
            senderButton.isUserInteractionEnabled = true
        }
        
    }
    
    @IBOutlet weak var timeOfDayDatePicker: UIDatePicker! // swiftlint:disable:this private_outlet
    
    @IBAction private func didUpdateTimeOfDay(_ sender: Any) {
        delegate.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    weak var delegate: DogsReminderWeeklyViewControllerDelegate! = nil
    
    var passedTimeOfDay: Date?
    
    var passedWeekDays: [Int]? = [1, 2, 3, 4, 5, 6, 7]
    
    var initalValuesChanged: Bool {
        if weekdays != passedWeekDays {
            return true
        }
        else if timeOfDayDatePicker.date != passedTimeOfDay {
            return true
        }
        return false
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWeekdays()
        
        timeOfDayDatePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        
        // keep duplicate as without it the user can see the .asyncafter visual scroll, but this duplicate stops a value changed not being called on first value change bug
        if let passedTimeOfDay = passedTimeOfDay {
            self.timeOfDayDatePicker.date = passedTimeOfDay
        }
        else {
            self.timeOfDayDatePicker.date = Date.roundDate(targetDate: Date(), roundingInterval: TimeInterval(60 * timeOfDayDatePicker.minuteInterval), roundingMethod: .up)
            passedTimeOfDay = timeOfDayDatePicker.date
        }
        
        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.timeOfDayDatePicker.date = self.timeOfDayDatePicker.date
        }
        
        dayOfWeekBackgrounds.forEach { background in
            self.view.insertSubview(background, belowSubview: saturdayButton)
            self.view.insertSubview(background, belowSubview: mondayButton)
            self.view.insertSubview(background, belowSubview: tuesdayButton)
            self.view.insertSubview(background, belowSubview: wednesdayButton)
            self.view.insertSubview(background, belowSubview: thursdayButton)
            self.view.insertSubview(background, belowSubview: fridayButton)
            self.view.insertSubview(background, belowSubview: sundayButton)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        for constraint in interDayOfWeekConstraints {
            // the distance between week day buttons should be 8 points on a 414 point screen, so this adjusts that ratio to fit any width of screen
            constraint.constant = (8.0 / 414.0) * self.view.safeAreaLayoutGuide.layoutFrame.width
        }
    }
    
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
    
}
