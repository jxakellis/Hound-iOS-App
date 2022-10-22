//
//  DogsReminderMonthlyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/13/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderMonthlyViewControllerDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsReminderMonthlyViewController: UIViewController {
    
    // MARK: - IB
    @IBOutlet weak var timeOfDayDatePicker: UIDatePicker! // swiftlint:disable:this private_outlet
    
    @IBAction private func didUpdateTimeOfDay(_ sender: Any) {
        delegate.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    weak var delegate: DogsReminderMonthlyViewControllerDelegate! = nil
    
    var passedTimeOfDay: Date?
    
    var initalValuesChanged: Bool {
        return (passedTimeOfDay != timeOfDayDatePicker.date) ? true : false
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // put no date datePicker.minimumDate because when the user goes to select the time of day, it causes weird selection issues. we already handle the case if they selected a time in the past (just use that day of month for the next month) so no need to block anything
        
    }
    
}
