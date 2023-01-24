//
//  DogsReminderOneTimeViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderOneTimeViewControllerDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsReminderOneTimeViewController: UIViewController {
    
    // MARK: - IB
    @IBOutlet private weak var datePicker: UIDatePicker!
    
    @IBAction private func didUpdateDatePicker(_ sender: Any) {
        delegate.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    weak var delegate: DogsReminderOneTimeViewControllerDelegate! = nil
    
    var passedDate: Date?
    
    var initalValuesChanged: Bool {
        if passedDate != oneTimeDate {
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns the datecomponets  selected
    var oneTimeDate: Date {
        get {
            return datePicker.date
        }
        set (date) {
            datePicker.date = date
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        
        // keep duplicate as without it the user can see the .asyncafter visual scroll, but this duplicate stops a value changed not being called on first value change bug
        if let passedDate = passedDate {
            oneTimeDate = passedDate
        }
        else {
            oneTimeDate = Date.roundDate(targetDate: Date(), roundingInterval: TimeInterval(60 * datePicker.minuteInterval), roundingMethod: .up)
            passedDate = oneTimeDate
        }
        
        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.oneTimeDate = self.oneTimeDate
        }
        
        // they can't choose a one time alarm that isn't in the future, otherwise there is no point
        datePicker.minimumDate = Date.roundDate(targetDate: Date(), roundingInterval: TimeInterval(60 * datePicker.minuteInterval), roundingMethod: .up)
        
    }
    
}
