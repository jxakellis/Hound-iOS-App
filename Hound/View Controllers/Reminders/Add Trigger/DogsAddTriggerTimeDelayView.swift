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
}

final class DogsAddTriggerTimeDelayView: HoundView {
    
    // MARK: - Elements
    
    private lazy var countdownDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 240, compressionResistancePriority: 240)
        datePicker.datePickerMode = .countDownTimer
        datePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        datePicker.countDownDuration = ClassConstant.TriggerConstant.defaultTriggerTimeDelay
        datePicker.addTarget(self, action: #selector(didUpdateCountdown), for: .valueChanged)
        return datePicker
    }()
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryRegularLabel
        label.textColor = UIColor.label
        return label
    }()
    
    @objc private func didUpdateCountdown(_ sender: Any) {
        self.errorMessage = nil
        updateDescriptionLabel()
        delegate?.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddTriggerTimeDelayViewDelegate?
    
    var currentTimeDelay: Double? {
        countdownDatePicker.countDownDuration
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddTriggerTimeDelayViewDelegate, forTimeDelay: Double?) {
        delegate = forDelegate
        if let delay = forTimeDelay {
            countdownDatePicker.countDownDuration = delay
        }
        
        updateDescriptionLabel()
    }
    
    // MARK: - Functions
    
    private func updateDescriptionLabel() {
        descriptionLabel.text = "Reminder will go off \(countdownDatePicker.countDownDuration.readable(capitalizeWords: false, abreviateWords: false)) after the log is added"
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(descriptionLabel)
        addSubview(countdownDatePicker)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        NSLayoutConstraint.activate([
            countdownDatePicker.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            countdownDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            countdownDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            countdownDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            countdownDatePicker.createHeightMultiplier(ConstraintConstant.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            countdownDatePicker.createMaxHeight(ConstraintConstant.Input.megaDatePickerMaxHeight)
        ])
    }
}
