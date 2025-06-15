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

    private let countdownDatePicker: GeneralUIDatePicker = {
        let datePicker = GeneralUIDatePicker(huggingPriority: 240, compressionResistancePriority: 240)
        datePicker.datePickerMode = .countDownTimer
        return datePicker
    }()
    
    // MARK: - Additional UI Elements
    private let countdownDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "A recurring reminder sounds an alarm at countdown's end and then automatically restarts"
        label.textAlignment = .center
        label.numberOfLines = 0
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
        
        countdownDatePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        countdownDatePicker.countDownDuration = initialCountdownDuration ?? ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
        initialCountdownDuration = countdownDatePicker.countDownDuration

        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.countdownDatePicker.countDownDuration = self.countdownDatePicker.countDownDuration
        }
    }

    // MARK: - Setup

    func setup(forDelegate: DogsAddReminderCountdownViewControllerDelegate, forCountdownDuration: Double?) {
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
        NSLayoutConstraint.activate([
            countdownDatePicker.topAnchor.constraint(equalTo: countdownDescriptionLabel.bottomAnchor, constant: 10),
            countdownDatePicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            countdownDatePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            countdownDatePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        
            countdownDescriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            countdownDescriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            countdownDescriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        
        ])
        
    }
}
