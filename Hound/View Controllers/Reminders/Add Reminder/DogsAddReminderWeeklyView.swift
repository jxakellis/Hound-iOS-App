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
    
    private lazy var weekdayStack: HoundStackView = {
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
        datePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        datePicker.preferredDatePickerStyle = .wheels
        
        datePicker.date = Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * datePicker.minuteInterval), roundingMethod: .up)
        
        datePicker.addTarget(self, action: #selector(didUpdateTimeOfDay), for: .valueChanged)
        
        return datePicker
    }()
    
    @objc private func didToggleWeekdayButton(_ sender: Any) {
        delegate?.willDismissKeyboard()
        
        guard let senderButton = sender as? HoundButton else {
            return
        }
        
        senderButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: VisualConstant.AnimationConstant.selectUIElement) {
            if senderButton.tag == VisualConstant.ViewTagConstant.weekdayEnabled {
                self.disableWeekdayButton(senderButton)
            }
            else {
                self.enabledWeekdayButton(senderButton)
            }
        } completion: { _ in
            senderButton.isUserInteractionEnabled = true
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
    
    /// Converts enabled buttons to an array of day of weeks according to CalendarComponents.weekdays, 1 being sunday and 7 being saturday
    var currentWeekdays: [Int]? {
        var days: [Int] = []
        
        weekdayButtons.forEach { button in
            guard button.tag == VisualConstant.ViewTagConstant.weekdayEnabled else {
                return
            }
            days.append(valueForWeekdayButton(button))
        }
        
        return days.isEmpty ? nil : days
    }
    /// timeOfDayDatePicker.date
    var currentTimeOfDay: Date? {
        timeOfDayDatePicker.date
    }
    
    private lazy var initialWeekdays: [Int] = weekdayButtons.compactMap { button in valueForWeekdayButton(button) }
    private var initialTimeOfDayDate: Date?
    var didUpdateInitialValues: Bool {
        if currentWeekdays != initialWeekdays {
            return true
        }
        if timeOfDayDatePicker.date != initialTimeOfDayDate {
            return true
        }
        
        return false
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddReminderWeeklyViewDelegate, forTimeOfDay: Date?, forWeekdays: [Int]?) {
        delegate = forDelegate
        initialTimeOfDayDate = forTimeOfDay
        initialWeekdays = forWeekdays ?? initialWeekdays
        
        timeOfDayDatePicker.date = forTimeOfDay ?? timeOfDayDatePicker.date
        weekdayButtons.forEach { button in
            let value = valueForWeekdayButton(button)
            if (forWeekdays ?? []).contains(value) {
                enabledWeekdayButton(button)
            }
            else {
                disableWeekdayButton(button)
            }
        }
        
    }
    
    // MARK: - Functions
    
    private func applyWeekdayButtonStyle(_ button: HoundButton) {
        button.backgroundCircleTintColor = .systemBackground
        disableWeekdayButton(button)
        button.addTarget(self, action: #selector(didToggleWeekdayButton), for: .touchUpInside)
    }
    private func enabledWeekdayButton(_ button: HoundButton) {
        button.tag = VisualConstant.ViewTagConstant.weekdayEnabled
        button.tintColor = .systemBlue
    }
    private func disableWeekdayButton(_ button: HoundButton) {
        button.tag = VisualConstant.ViewTagConstant.weekdayDisabled
        button.tintColor = .systemGray4
    }
    private func valueForWeekdayButton(_ button: HoundButton) -> Int {
        // CalendarComponents.weekdays starts at 1 for Sunday
        return weekdayButtons.firstIndex(of: button)! + 1 // swiftlint:disable:this force_unwrapping
    }
    private func weekdayButtonForValue(_ value: Int) -> HoundButton? {
        guard value >= 1 && value <= 7 else {
            return nil
        }
        return weekdayButtons[value - 1] // CalendarComponents.weekdays starts at 1 for Sunday
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
                button.createHeightMultiplier(ConstraintConstant.Button.miniCircleHeightMultiplier, relativeToWidthOf: self),
                button.createMaxHeight(ConstraintConstant.Button.miniCircleMaxHeight)
            ])
        }
        
        // timeOfDayDatePicker
        NSLayoutConstraint.activate([
            timeOfDayDatePicker.topAnchor.constraint(equalTo: weekdayStack.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            timeOfDayDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            timeOfDayDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            timeOfDayDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            timeOfDayDatePicker.createHeightMultiplier(ConstraintConstant.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            timeOfDayDatePicker.createMaxHeight(ConstraintConstant.Input.megaDatePickerMaxHeight)
        ])
    }
    
}
