//
//  DogsAddReminderCountdownViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderCountdownViewControllerDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsAddReminderCountdownViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private weak var countdownDatePicker: UIDatePicker!
    @IBAction private func didUpdateCountdown(_ sender: Any) {
        delegate.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddReminderCountdownViewControllerDelegate!
    
    /// countdownDatePicker.countDownDuration
    var currentCountdownDuration: TimeInterval? {
        return countdownDatePicker.countDownDuration
    }
    
    private var initialCountdownDuration: TimeInterval?
    var didUpdateInitialValues: Bool {
        if countdownDatePicker.countDownDuration != initialCountdownDuration {
            return true
        }
        
        return false
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countdownDatePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        countdownDatePicker.countDownDuration = initialCountdownDuration ?? ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
        initialCountdownDuration = countdownDatePicker.countDownDuration
        
        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.countdownDatePicker.countDownDuration = self.countdownDatePicker.countDownDuration
        }
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: DogsAddReminderCountdownViewControllerDelegate, forCountdownDuration: TimeInterval?) {
        delegate = forDelegate
        initialCountdownDuration = forCountdownDuration
    }
    
}
