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

final class DogsAddReminderCountdownViewController: GeneralUIViewController {

    // MARK: - Elements

    private let countdownDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.contentMode = .scaleToFill
        datePicker.setContentHuggingPriority(UILayoutPriority(240), for: .horizontal)
        datePicker.setContentHuggingPriority(UILayoutPriority(240), for: .vertical)
        datePicker.setContentCompressionResistancePriority(UILayoutPriority(740), for: .horizontal)
        datePicker.setContentCompressionResistancePriority(UILayoutPriority(740), for: .vertical)
        datePicker.contentHorizontalAlignment = .center
        datePicker.contentVerticalAlignment = .center
        datePicker.datePickerMode = .countDownTimer
        datePicker.countDownDuration = 5400
        datePicker.minuteInterval = 5
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        return datePicker
    }()
    
    // MARK: - Additional UI Elements
    private let countdownDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.text = "A recurring reminder sounds an alarm at countdown's end and then automatically restarts"
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        return label
    }()
    @objc private func didUpdateCountdown(_ sender: Any) {
        delegate.willDismissKeyboard()
    }

    // MARK: - Properties

    private weak var delegate: DogsAddReminderCountdownViewControllerDelegate!

    /// countdownDatePicker.countDownDuration
    var currentCountdownDuration: Double? {
        countdownDatePicker.countDownDuration
    }

    private var initialCountdownDuration: Double?
    var didUpdateInitialValues: Bool {
        if countdownDatePicker.countDownDuration != initialCountdownDuration {
            return true
        }

        return false
    }

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGeneratedViews()
        
        countdownDatePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        countdownDatePicker.countDownDuration = initialCountdownDuration ?? ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
        initialCountdownDuration = countdownDatePicker.countDownDuration

        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.countdownDatePicker.countDownDuration = self.countdownDatePicker.countDownDuration
        }
    }

    // MARK: - Functions

    func setup(forDelegate: DogsAddReminderCountdownViewControllerDelegate, forCountdownDuration: Double?) {
        delegate = forDelegate
        initialCountdownDuration = forCountdownDuration
    }

}

extension DogsAddReminderCountdownViewController {
    private func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        addSubViews()
        setupConstraints()
    }

    private func addSubViews() {
        view.addSubview(countdownDatePicker)
        countdownDatePicker.addTarget(self, action: #selector(didUpdateCountdown), for: .editingChanged)
        countdownDatePicker.addTarget(self, action: #selector(didUpdateCountdown), for: .valueChanged)
        view.addSubview(countdownDescriptionLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            countdownDatePicker.topAnchor.constraint(equalTo: countdownDescriptionLabel.bottomAnchor, constant: 10),
            countdownDatePicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            countdownDatePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            countdownDatePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        
            countdownDescriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            countdownDescriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            countdownDescriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        
        ])
        
    }
}
