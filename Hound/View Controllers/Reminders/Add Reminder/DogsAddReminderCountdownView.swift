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
        datePicker.minuteInterval = Constant.Development.minuteInterval
        datePicker.countDownDuration = Constant.Class.ReminderComponent.defaultCountdownExecutionInterval
        
        datePicker.addTarget(self, action: #selector(didUpdateCountdown), for: .editingChanged)
        datePicker.addTarget(self, action: #selector(didUpdateCountdown), for: .valueChanged)
        
        return datePicker
    }()
    
    private let countdownDescriptionLabel: HoundLabel = {
        let label = HoundLabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Constant.Visual.Font.secondaryRegularLabel
        label.textColor = UIColor.label
        return label
    }()
    @objc private func didUpdateCountdown(_ sender: Any) {
        updateDescriptionLabel()
        delegate?.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddReminderCountdownViewDelegate?
    
    /// countdownDatePicker.countDownDuration
    var currentCountdownDuration: Double? {
        countdownDatePicker.countDownDuration
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddReminderCountdownViewDelegate, forCountdownDuration: Double?) {
        delegate = forDelegate
        
        countdownDatePicker.countDownDuration = forCountdownDuration ?? countdownDatePicker.countDownDuration
        updateDescriptionLabel()
    }
    
    // MARK: - Functions
    
    private func updateDescriptionLabel() {
        countdownDescriptionLabel.text = "Reminder will sound every \((currentCountdownDuration ?? 0).readable(capitalizeWords: false, abbreviationLevel: .long)) then automatically restart"
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
            countdownDatePicker.topAnchor.constraint(equalTo: countdownDescriptionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            countdownDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            countdownDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            countdownDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            countdownDatePicker.createHeightMultiplier(Constant.Constraint.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            countdownDatePicker.createMaxHeight(Constant.Constraint.Input.megaDatePickerMaxHeight)
        ])
    }
    
}
