//
//  DogsAddTriggerTimeDelayView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/8/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddTriggerTimeDelayViewDelegate: AnyObject {
    func willDismissKeyboard()
    func didUpdateDescriptionLabel()
}

final class DogsAddTriggerTimeDelayView: HoundView {
    
    // MARK: - Elements
    
    private lazy var countdownDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 240, compressionResistancePriority: 240)
        datePicker.datePickerMode = .countDownTimer
        datePicker.minuteInterval = Constant.Development.minuteInterval
        datePicker.countDownDuration = Constant.Class.Trigger.defaultTriggerTimeDelay
        datePicker.addTarget(self, action: #selector(didUpdateCountdown), for: .valueChanged)
        return datePicker
    }()
    
    @objc private func didUpdateCountdown(_ sender: Any) {
        self.errorMessage = nil
        delegate?.willDismissKeyboard()
        delegate?.didUpdateDescriptionLabel()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddTriggerTimeDelayViewDelegate?
    
    var currentComponent: TriggerTimeDelayComponents {
        TriggerTimeDelayComponents(triggerTimeDelay: countdownDatePicker.countDownDuration)
    }
    
    // MARK: - Setup
    
    func setup(
        delegate: DogsAddTriggerTimeDelayViewDelegate,
        components: TriggerTimeDelayComponents?
    ) {
        self.delegate = delegate
        if let delay = components?.triggerTimeDelay {
            countdownDatePicker.countDownDuration = delay
        }
        
        delegate.didUpdateDescriptionLabel()
    }
    
    // MARK: - Functions
    
    var descriptionLabelText: String {
            "Reminder will be sent \(countdownDatePicker.countDownDuration.readable(capitalizeWords: false, abbreviationLevel: .long)) after the log is added"
        }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(countdownDatePicker)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        NSLayoutConstraint.activate([
            countdownDatePicker.topAnchor.constraint(equalTo: topAnchor),
            countdownDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            countdownDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            countdownDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            countdownDatePicker.createHeightMultiplier(Constant.Constraint.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            countdownDatePicker.createMaxHeight(Constant.Constraint.Input.megaDatePickerMaxHeight)
        ])
    }
}
