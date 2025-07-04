//
//  DogsAddReminderCountdownVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderCountdownVCDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsAddReminderCountdownVC: HoundViewController {

    // MARK: - Elements

    private let countdownDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 240, compressionResistancePriority: 240)
        datePicker.datePickerMode = .countDownTimer
        return datePicker
    }()
    
    private let countdownDescriptionLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "A recurring reminder sounds an alarm at countdown's end and then automatically restarts"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.textColor = .systemGray
        return label
    }()
    @objc private func didUpdateCountdown(_ sender: Any) {
        delegate?.willDismissKeyboard()
    }

    // MARK: - Properties

    private weak var delegate: DogsAddReminderCountdownVCDelegate?

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
        
        countdownDatePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        countdownDatePicker.countDownDuration = initialCountdownDuration ?? ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
        initialCountdownDuration = countdownDatePicker.countDownDuration

        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.countdownDatePicker.countDownDuration = self.countdownDatePicker.countDownDuration
        }
    }

    // MARK: - Setup

    func setup(forDelegate: DogsAddReminderCountdownVCDelegate, forCountdownDuration: Double?) {
        delegate = forDelegate
        initialCountdownDuration = forCountdownDuration
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        view.addSubview(countdownDatePicker)
        countdownDatePicker.addTarget(self, action: #selector(didUpdateCountdown), for: .editingChanged)
        countdownDatePicker.addTarget(self, action: #selector(didUpdateCountdown), for: .valueChanged)
        view.addSubview(countdownDescriptionLabel)
    }

    override func setupConstraints() {
        super.setupConstraints()

        // countdownDescriptionLabel
        let countdownDescriptionLabelTop = countdownDescriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        let countdownDescriptionLabelLeading = countdownDescriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        let countdownDescriptionLabelTrailing = countdownDescriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)

        // countdownDatePicker
        let countdownDatePickerTop = countdownDatePicker.topAnchor.constraint(equalTo: countdownDescriptionLabel.bottomAnchor, constant: 10)
        let countdownDatePickerBottom = countdownDatePicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        let countdownDatePickerLeading = countdownDatePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        let countdownDatePickerTrailing = countdownDatePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)

        NSLayoutConstraint.activate([
            // countdownDescriptionLabel
            countdownDescriptionLabelTop,
            countdownDescriptionLabelLeading,
            countdownDescriptionLabelTrailing,

            // countdownDatePicker
            countdownDatePickerTop,
            countdownDatePickerBottom,
            countdownDatePickerLeading,
            countdownDatePickerTrailing
        ])
    }

}
