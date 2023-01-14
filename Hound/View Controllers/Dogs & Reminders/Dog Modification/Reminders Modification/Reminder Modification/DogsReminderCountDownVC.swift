//
//  DogsReminderCountdownViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderCountdownViewControllerDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsReminderCountdownViewController: UIViewController {
    
    // MARK: - IB
    
    @IBOutlet private weak var countdown: UIDatePicker!
    
    @IBAction private func willUpdateCountdown(_ sender: Any) {
        delegate.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    weak var delegate: DogsReminderCountdownViewControllerDelegate! = nil
    
    var passedInterval: TimeInterval?
    
    var initalValuesChanged: Bool {
        if countdownDuration != passedInterval {
            return true
        }
        else {
            return false
        }
    }
    
    var countdownDuration: TimeInterval {
        get {
            return countdown.countDownDuration
        }
        set (duration) {
            countdown.countDownDuration = duration
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countdown.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        
        // keep duplicate as without it the user can see the .asyncafter visual scroll, but this duplicate stops a value changed not being called on first value change bug
        if let passedInterval = passedInterval {
            countdownDuration = passedInterval
        }
        else {
            countdownDuration = ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
            passedInterval = countdownDuration
        }
        
        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let passedInterval = self.passedInterval {
                self.countdownDuration = passedInterval
            }
            else {
                self.countdownDuration = ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
            }
        }
        
    }
    
}
