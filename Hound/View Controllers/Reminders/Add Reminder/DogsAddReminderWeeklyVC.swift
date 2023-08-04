//
//  DogsAddReminderWeeklyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderWeeklyViewControllerDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsAddReminderWeeklyViewController: UIViewController {

    // MARK: - IB

    @IBOutlet private var interDayOfWeekConstraints: [NSLayoutConstraint]!

    @IBOutlet private weak var sundayButton: GeneralWithBackgroundUIButton!
    @IBOutlet private weak var mondayButton: GeneralWithBackgroundUIButton!
    @IBOutlet private weak var tuesdayButton: GeneralWithBackgroundUIButton!
    @IBOutlet private weak var wednesdayButton: GeneralWithBackgroundUIButton!
    @IBOutlet private weak var thursdayButton: GeneralWithBackgroundUIButton!
    @IBOutlet private weak var fridayButton: GeneralWithBackgroundUIButton!
    @IBOutlet private weak var saturdayButton: GeneralWithBackgroundUIButton!

    @IBAction private func didToggleWeekdayButton(_ sender: Any) {
        delegate.willDismissKeyboard()

        guard let senderButton = sender as? GeneralWithBackgroundUIButton else {
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
        } completion: { _ in
            senderButton.isUserInteractionEnabled = true
        }

    }

    @IBOutlet private weak var timeOfDayDatePicker: UIDatePicker!
    @IBAction private func didUpdateTimeOfDay(_ sender: Any) {
        delegate.willDismissKeyboard()
    }

    // MARK: - Properties

    private weak var delegate: DogsAddReminderWeeklyViewControllerDelegate!

    /// Converts enabled buttons to an array of day of weeks according to CalendarComponents.weekdays, 1 being sunday and 7 being saturday
    var currentWeekdays: [Int]? {
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
    /// timeOfDayDatePicker.date
    var currentTimeOfDay: Date? {
        timeOfDayDatePicker.date
    }

    private var initialWeekdays: [Int] = [1, 2, 3, 4, 5, 6, 7]
    private var initialTimeOfDayDate: Date?
    var didUpdateInitialValues: Bool {
        if currentWeekdays != initialWeekdays {
            return true
        }
        if timeOfDayDatePicker.date != initialTimeOfDayDate {
            return true
        }

        return false
    }

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        // Make all the dayOfWeekButtons look disabled
        for dayOfWeekButton in [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton] {
            guard let dayOfWeekButton = dayOfWeekButton else {
                continue
            }

            dayOfWeekButton.tintColor = UIColor.systemGray4
            dayOfWeekButton.tag = VisualConstant.ViewTagConstant.weekdayDisabled
        }

        // Make all the dayOfWeekButtons look enabled (if they are in the array)
        for dayOfWeek in initialWeekdays {
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
        initialWeekdays = currentWeekdays ?? initialWeekdays

        timeOfDayDatePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        timeOfDayDatePicker.date = initialTimeOfDayDate ?? Date.roundDate(targetDate: Date(), roundingInterval: TimeInterval(60 * timeOfDayDatePicker.minuteInterval), roundingMethod: .up)
        initialTimeOfDayDate = timeOfDayDatePicker.date

        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.timeOfDayDatePicker.date = self.timeOfDayDatePicker.date
        }
    }

    /// Certain views must be adapted in viewDidLayoutSubviews as properties (such as frames) are not updated until the subviews are laid out (before that point in time they hold the placeholder storyboard value). However, viewDidLayoutSubviews is called multiple times, therefore we must lock it to executing certain code once with this variable. viewDidLayoutSubviews is the superior choice to viewDidAppear as viewDidAppear has the downside of performing these changes once the user can see the view
    private var didSetupCustomSubviews: Bool = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // DogsAddReminderWeeklyViewController IS EMBEDDED inside other view controllers. This means IT DOES NOT have any safe area insets. Only the view controllers that are presented onto MainTabBarController or are in the navigation stack have safe area insets. This is because those views take up the whole screen, so they MUST consider the phone's safe area (i.e. top bar with time, wifi, and battery and bottom bar).

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

    func setup(forDelegate: DogsAddReminderWeeklyViewControllerDelegate, forTimeOfDay: Date?, forWeekdays: [Int]?) {
        delegate = forDelegate
        initialTimeOfDayDate = forTimeOfDay
        initialWeekdays = forWeekdays ?? initialWeekdays
    }

}
