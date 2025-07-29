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
    
    private(set) var currentTimeZone: TimeZone = .current
    
    private var weekdayButtons: [HoundButton] {
        return [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton]
    }
    
    private var currentWeekdays: [Weekday] {
        var days: [Weekday] = []
        
        weekdayButtons.forEach { button in
            guard button.tag == Constant.Visual.ViewTag.weekdayEnabled else {
                return
            }
            
            days.append(valueForWeekdayButton(button))
        }
        
        return days
    }
    
    /// The weekly component represented by the current UI state.
    var currentComponent: WeeklyComponents? {
        guard !currentWeekdays.isEmpty else { return nil }
        let calendar = Calendar.fromZone(currentTimeZone)
        let comps = calendar.dateComponents([.hour, .minute], from: timeOfDayDatePicker.date)
        let hour = comps.hour ?? Constant.Class.ReminderComponent.defaultZonedHour
        let minute = comps.minute ?? Constant.Class.ReminderComponent.defaultZonedMinute
        
        let component = WeeklyComponents(zonedHour: hour, zonedMinute: minute)
        _ = component.setZonedWeekdays(currentWeekdays)
        return component
    }
    
    // MARK: - Setup
    
    func setup(
        forDelegate: DogsAddReminderWeeklyViewDelegate,
        forComponents: WeeklyComponents?,
        forTimeZone: TimeZone
    ) {
        delegate = forDelegate
        currentTimeZone = forTimeZone
        timeOfDayDatePicker.timeZone = forTimeZone
        
        if let components = forComponents {
            let calendar = Calendar.fromZone(currentTimeZone)
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
            dateComponents.hour = components.zonedHour
            dateComponents.minute = components.zonedMinute
            dateComponents.second = 0
            dateComponents.timeZone = forTimeZone
            timeOfDayDatePicker.date = calendar.date(from: dateComponents) ?? timeOfDayDatePicker.date
            
            weekdayButtons.forEach { button in
                let value = valueForWeekdayButton(button)
                if components.zonedWeekdays.contains(value) {
                    enabledWeekdayButton(button)
                }
                else {
                    disableWeekdayButton(button)
                }
            }
            
        }
        else {
            weekdayButtons.forEach { enabledWeekdayButton($0) }
        }
    }
    
    func updateDisplayedTimeZone(_ newTimeZone: TimeZone) {
        guard newTimeZone != currentTimeZone else { return }
        
        let calendar = Calendar.fromZone(currentTimeZone)
        let oldComps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: timeOfDayDatePicker.date)
        let day = oldComps.day ?? 1
        let hour = oldComps.hour ?? 0
        let minute = oldComps.minute ?? 0
        
        let converted = currentTimeZone.convert(
            day: day,
            hour: hour,
            minute: minute,
            to: newTimeZone,
            referenceDate: timeOfDayDatePicker.date
        )
        
        var newComps = DateComponents()
        newComps.year = oldComps.year
        newComps.month = oldComps.month
        newComps.day = converted.day
        newComps.hour = converted.hour
        newComps.minute = converted.minute
        newComps.second = 0
        newComps.timeZone = newTimeZone
        
        if let newDate = calendar.date(from: newComps) {
            timeOfDayDatePicker.timeZone = newTimeZone
            timeOfDayDatePicker.date = newDate
        }
        
        let newWeekdays = currentTimeZone.convert(
            weekdays: currentWeekdays,
            hour: hour,
            minute: minute,
            to: newTimeZone
        )
        weekdayButtons.forEach { button in
            let value = valueForWeekdayButton(button)
            if newWeekdays.contains(value) {
                enabledWeekdayButton(button)
            }
            else {
                disableWeekdayButton(button)
            }
        }
        
        currentTimeZone = newTimeZone
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
