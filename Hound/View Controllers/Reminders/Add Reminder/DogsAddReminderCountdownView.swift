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
    func didUpdateDescriptionLabel()
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
    
    @objc private func didUpdateCountdown(_ sender: Any) {
        delegate?.willDismissKeyboard()
        delegate?.didUpdateDescriptionLabel()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddReminderCountdownViewDelegate?
    
    var currentComponent: CountdownComponents {
        CountdownComponents(executionInterval: countdownDatePicker.countDownDuration)
    }
    
    var descriptionLabelText: String {
        return "Reminder will sound every \(countdownDatePicker.countDownDuration.readable(capitalizeWords: false, abbreviationLevel: .long)) then automatically restart"
    }
    
    // MARK: - Setup
    
    func setup(delegate: DogsAddReminderCountdownViewDelegate,
               components: CountdownComponents?) {
        self.delegate = delegate
        
        countdownDatePicker.countDownDuration = components?.executionInterval ??
        countdownDatePicker.countDownDuration
        delegate.didUpdateDescriptionLabel()
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(countdownDatePicker)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
    
        // countdownDatePicker
        NSLayoutConstraint.activate([
            countdownDatePicker.topAnchor.constraint(equalTo: topAnchor),
            countdownDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            countdownDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            countdownDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            countdownDatePicker.createHeightMultiplier(Constant.Constraint.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            countdownDatePicker.createMaxHeight(Constant.Constraint.Input.megaDatePickerMaxHeight)
        ])
    }
    
}
