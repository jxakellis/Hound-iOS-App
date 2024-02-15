//
//  DogsAddReminderOneTimeViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderOneTimeViewControllerDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsAddReminderOneTimeViewController: GeneralUIViewController {

    // MARK: - IB

    @IBOutlet private weak var oneTimeDatePicker: UIDatePicker!

    @IBAction private func didUpdateOneTimeDatePicker(_ sender: Any) {
        delegate.willDismissKeyboard()
    }

    // MARK: - Properties

    private weak var delegate: DogsAddReminderOneTimeViewControllerDelegate!

    var oneTimeDate: Date? {
        oneTimeDatePicker.date
    }

    private var initialOneTimeDate: Date?
    var didUpdateInitialValues: Bool {
        if oneTimeDate != initialOneTimeDate {
            return true
        }

        return oneTimeDate != initialOneTimeDate
    }

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        oneTimeDatePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        oneTimeDatePicker.date = initialOneTimeDate ?? Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * oneTimeDatePicker.minuteInterval), roundingMethod: .up)
        initialOneTimeDate = oneTimeDatePicker.date

        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.oneTimeDatePicker = self.oneTimeDatePicker
        }

        // they can't choose a one time alarm that isn't in the future, otherwise there is no point
        oneTimeDatePicker.minimumDate = Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * oneTimeDatePicker.minuteInterval), roundingMethod: .up)
    }

    // MARK: - Functions

    func setup(forDelegate: DogsAddReminderOneTimeViewControllerDelegate, forOneTimeDate: Date?) {
        delegate = forDelegate
        initialOneTimeDate = forOneTimeDate
    }

}
