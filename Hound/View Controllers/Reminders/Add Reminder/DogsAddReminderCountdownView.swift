//
//  DogsAddReminderCountdownVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderCountdownViewDelegate: AnyObject {
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
        label.font = VisualConstant.FontConstant.secondaryRegularLabel
        label.textColor = UIColor.label
        return label
    }()
    @objc private func didUpdateCountdown(_ sender: Any) {
        delegate?.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddReminderCountdownViewDelegate?
    
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
    
    func setup(forDelegate: DogsAddReminderCountdownViewDelegate, forCountdownDuration: Double?) {
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
            countdownDescriptionLabel.topAnchor.constraint(equalTo: topAnchor),
            countdownDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            countdownDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // countdownDatePicker
        NSLayoutConstraint.activate([
            countdownDatePicker.topAnchor.constraint(equalTo: countdownDescriptionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            countdownDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            countdownDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            countdownDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            countdownDatePicker.createHeightMultiplier(ConstraintConstant.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            countdownDatePicker.createMaxHeight(ConstraintConstant.Input.megaDatePickerMaxHeight)
        ])
    }
    
}
