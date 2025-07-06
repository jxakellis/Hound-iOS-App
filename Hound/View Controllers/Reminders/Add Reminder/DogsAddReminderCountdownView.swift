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

final class DogsAddReminderCountdownView: HoundView {
    
    // MARK: - Elements
    
    private lazy var countdownDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 240, compressionResistancePriority: 240)
        datePicker.datePickerMode = .countDownTimer
        datePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        datePicker.countDownDuration = ClassConstant.ReminderComponentConstant.defaultCountdownExecutionInterval
        
        datePicker.addTarget(self, action: #selector(didUpdateCountdown), for: .editingChanged)
        datePicker.addTarget(self, action: #selector(didUpdateCountdown), for: .valueChanged)
        
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
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddReminderCountdownVCDelegate, forCountdownDuration: Double?) {
        delegate = forDelegate
        initialCountdownDuration = forCountdownDuration
        
        countdownDatePicker.countDownDuration = forCountdownDuration ?? countdownDatePicker.countDownDuration
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(countdownDatePicker)
        addSubview(countdownDescriptionLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // countdownDescriptionLabel
        NSLayoutConstraint.activate([
            countdownDescriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: ConstraintConstant.Spacing.absoluteVerticalInset),
            countdownDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            countdownDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset
            )
        ])
        
        // countdownDatePicker
        NSLayoutConstraint.activate([
            countdownDatePicker.topAnchor.constraint(equalTo: countdownDescriptionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            countdownDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            countdownDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            countdownDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVerticalInset
            )
//            countdownDatePicker.createHeightMultiplier(
//                ConstraintConstant.Input.datePickerHeightMultiplier,
//                relativeToWidthOf: view
//            ),
//            countdownDatePicker.createMaxHeight(
//                ConstraintConstant.Input.datePickerMaxHeight
//            )
        ])
    }
    
}
