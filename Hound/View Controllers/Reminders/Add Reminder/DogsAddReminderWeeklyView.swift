//
//  DogsAddReminderWeeklyVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderWeeklyViewDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsAddReminderWeeklyView: HoundView {
    
    // MARK: - Elements
    
    lazy var weekdayStack: HoundStackView = {
        let stack = HoundStackView()
        weekdayButtons.forEach { button in
            stack.addArrangedSubview(button)
        }
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private lazy var sundayButton: HoundButton = {
        let button = HoundButton()
        button.setImage(UIImage(systemName: "s.circle.fill"), for: .normal)
        applyWeekdayButtonStyle(button)
        return button
    }()
    
    private lazy var mondayButton: HoundButton = {
        let button = HoundButton()
        button.setImage(UIImage(systemName: "m.circle.fill"), for: .normal)
        applyWeekdayButtonStyle(button)
        return button
    }()
    
    private lazy var tuesdayButton: HoundButton = {
        let button = HoundButton()
        button.setImage(UIImage(systemName: "t.circle.fill"), for: .normal)
        applyWeekdayButtonStyle(button)
        return button
    }()
    
    private lazy var wednesdayButton: HoundButton = {
        let button = HoundButton()
        button.setImage(UIImage(systemName: "w.circle.fill"), for: .normal)
        applyWeekdayButtonStyle(button)
        return button
    }()
    
    private lazy var thursdayButton: HoundButton = {
        let button = HoundButton()
        button.setImage(UIImage(systemName: "t.circle.fill"), for: .normal)
        applyWeekdayButtonStyle(button)
        return button
    }()
    
    private lazy var fridayButton: HoundButton = {
        let button = HoundButton()
        button.setImage(UIImage(systemName: "f.circle.fill"), for: .normal)
        applyWeekdayButtonStyle(button)
        return button
    }()
    
    private lazy var saturdayButton: HoundButton = {
        let button = HoundButton()
        button.setImage(UIImage(systemName: "s.circle.fill"), for: .normal)
        applyWeekdayButtonStyle(button)
        return button
    }()
    
    private lazy var timeOfDayDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 240, compressionResistancePriority: 240)
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = Constant.Development.minuteInterval
        datePicker.preferredDatePickerStyle = .wheels
        
        datePicker.date = Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * datePicker.minuteInterval), roundingMethod: .up)
        
        datePicker.addTarget(self, action: #selector(didUpdateTimeOfDay), for: .valueChanged)
        
        return datePicker
    }()
    
    @objc private func didToggleWeekdayButton(_ sender: Any) {
        delegate?.willDismissKeyboard()
        
        guard let senderButton = sender as? HoundButton else { return }
        
        senderButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: Constant.Visual.Animation.selectSingleElement) {
            if senderButton.tag == Constant.Visual.ViewTag.weekdayEnabled {
                self.disableWeekdayButton(senderButton)
            }
            else {
                self.enabledWeekdayButton(senderButton)
            }
        } completion: { _ in
            senderButton.isUserInteractionEnabled = true
        }
        
        if !currentWeekdays.isEmpty {
            weekdayStack.errorMessage = nil
        }
    }
    
    @objc private func didUpdateTimeOfDay(_ sender: Any) {
        delegate?.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddReminderWeeklyViewDelegate?
    
    private var weekdayButtons: [HoundButton] {
        return [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton]
    }
    
    var currentWeekdays: [Weekday] {
        var days: [Weekday] = []
        
        weekdayButtons.forEach { button in
            guard button.tag == Constant.Visual.ViewTag.weekdayEnabled else {
                return
            }
            
            days.append(valueForWeekdayButton(button))
        }
        
        return days
    }
    /// timeOfDayDatePicker.date
    var currentTimeOfDay: Date? {
        timeOfDayDatePicker.date
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddReminderWeeklyViewDelegate, forTimeZone: TimeZone, forWeeklyComponent: WeeklyComponents) {
        delegate = forDelegate
        timeOfDayDatePicker.date = forTimeOfDay ?? timeOfDayDatePicker.date
        
        weekdayButtons.forEach { button in
            guard let forWeekdays = forWeekdays else {
                enabledWeekdayButton(button)
                return
            }
            
            let value = valueForWeekdayButton(button)
            if forWeekdays.contains(value) {
                enabledWeekdayButton(button)
            }
            else {
                disableWeekdayButton(button)
            }
        }
    }
    
    // MARK: - Functions
    
    private func applyWeekdayButtonStyle(_ button: HoundButton) {
        button.backgroundCircleTintColor = UIColor.systemBackground
        disableWeekdayButton(button)
        button.addTarget(self, action: #selector(didToggleWeekdayButton), for: .touchUpInside)
    }
    private func enabledWeekdayButton(_ button: HoundButton) {
        button.tag = Constant.Visual.ViewTag.weekdayEnabled
        button.tintColor = UIColor.systemBlue
    }
    private func disableWeekdayButton(_ button: HoundButton) {
        button.tag = Constant.Visual.ViewTag.weekdayDisabled
        button.tintColor = UIColor.systemGray4
    }
    private func valueForWeekdayButton(_ button: HoundButton) -> Weekday {
        switch button {
        case sundayButton: return .sunday
        case mondayButton: return .monday
        case tuesdayButton: return .tuesday
        case wednesdayButton: return .wednesday
        case thursdayButton: return .thursday
        case fridayButton: return .friday
        case saturdayButton: return .saturday
        default: fatalError("DogsAddReminderWeeklyView.valueForWeekdayButton: Unrecognized weekday button")
        }
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(weekdayStack)
        addSubview(timeOfDayDatePicker)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // weekdayStack
        NSLayoutConstraint.activate([
            weekdayStack.topAnchor.constraint(equalTo: topAnchor),
            weekdayStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            weekdayStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // weekdayButtons
        weekdayButtons.forEach { button in
            NSLayoutConstraint.activate([
                button.createSquareAspectRatio(),
                button.createHeightMultiplier(Constant.Constraint.Button.miniCircleHeightMultiplier, relativeToWidthOf: self),
                button.createMaxHeight(Constant.Constraint.Button.miniCircleMaxHeight)
            ])
        }
        
        // timeOfDayDatePicker
        NSLayoutConstraint.activate([
            timeOfDayDatePicker.topAnchor.constraint(equalTo: weekdayStack.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            timeOfDayDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            timeOfDayDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            timeOfDayDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            timeOfDayDatePicker.createHeightMultiplier(Constant.Constraint.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            timeOfDayDatePicker.createMaxHeight(Constant.Constraint.Input.megaDatePickerMaxHeight)
        ])
    }
    
}
