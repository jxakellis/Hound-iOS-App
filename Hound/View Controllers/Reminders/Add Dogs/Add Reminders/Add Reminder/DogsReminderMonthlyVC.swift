//
//  DogsReminderMonthlyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/13/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderMonthlyViewControllerDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsReminderMonthlyViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private weak var timeOfDayDatePicker: UIDatePicker!
    
    @IBAction private func didUpdateTimeOfDay(_ sender: Any) {
        delegate.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsReminderMonthlyViewControllerDelegate!
    
    // timeOfDayDatePicker.date
    var currentTimeOfDay: Date? {
        return timeOfDayDatePicker.date
    }
    
    private var initialTimeOfDay: Date?
    var didUpdateInitialValues: Bool {
        if currentTimeOfDay != initialTimeOfDay {
            return true
        }
        
        return currentTimeOfDay != initialTimeOfDay
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeOfDayDatePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        
        timeOfDayDatePicker.date = initialTimeOfDay ?? Date.roundDate(targetDate: Date(), roundingInterval: TimeInterval(60 * timeOfDayDatePicker.minuteInterval), roundingMethod: .up)
        initialTimeOfDay = timeOfDayDatePicker.date
        
        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.timeOfDayDatePicker.date = self.timeOfDayDatePicker.date
        }
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: DogsReminderMonthlyViewControllerDelegate, forTimeOfDay: Date?) {
        delegate = forDelegate
        initialTimeOfDay = forTimeOfDay
    }
    
}
