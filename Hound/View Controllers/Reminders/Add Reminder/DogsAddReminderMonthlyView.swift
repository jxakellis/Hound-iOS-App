//
//  DogsAddReminderMonthlyVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/13/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

protocol DogsAddReminderMonthlyViewDelegate: AnyObject {
    func willDismissKeyboard()
    func didUpdateDescriptionLabel()
}

final class DogsAddReminderMonthlyView: HoundView {
    
    // MARK: - Elements
    
    private lazy var timeOfDayDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 260, compressionResistancePriority: 260)
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minuteInterval = Constant.Development.minuteInterval
        
        datePicker.addTarget(self, action: #selector(didUpdateTimeOfDay), for: .valueChanged)
        
        datePicker.date = Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * datePicker.minuteInterval), roundingMethod: .up)
        
        return datePicker
    }()
    
    private let rollUnderDisclaimerLabel: HoundLabel = {
        let label = HoundLabel()
        label.textColor = UIColor.secondaryLabel
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var stack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(timeOfDayDatePicker)
        stack.addArrangedSubview(rollUnderDisclaimerLabel)
        stack.axis = .vertical
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        return stack
    }()
    
    @objc private func didUpdateTimeOfDay(_ sender: Any) {
        updateDescriptionLabel()
        delegate?.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddReminderMonthlyViewDelegate?
    private(set) var currentTimeZone: TimeZone = UserConfiguration.timeZone
    
    // timeOfDayDatePicker.date
    private var currentTimeOfDay: Date {
        timeOfDayDatePicker.date
    }
    
    /// Monthly component represented by the current UI state.
    var currentComponent: MonthlyComponents {
        let calendar = Calendar.fromZone(currentTimeZone)
        let comps = calendar.dateComponents(in: currentTimeZone, from: currentTimeOfDay)
        let day = comps.day ?? Constant.Class.ReminderComponent.defaultZonedDay
        let hour = comps.hour ?? Constant.Class.ReminderComponent.defaultZonedHour
        let minute = comps.minute ?? Constant.Class.ReminderComponent.defaultZonedMinute
        return MonthlyComponents(zonedDay: day, zonedHour: hour, zonedMinute: minute)
    }
    
    var descriptionLabelText: String {
        let comps = Calendar.fromZone(currentTimeZone).dateComponents([.day], from: timeOfDayDatePicker.date)
        let day = comps.day ?? 1
        
        let timeString = timeOfDayDatePicker.date.houndFormatted(
            .formatStyle(date: .omitted, time: .shortened),
            displayTimeZone: currentTimeZone
        )
        
        return "Reminder will sound on the \(day)\(day.daySuffix()) of each month at \(timeString)"
    }
    
    private var disclaimerLabelText: String? {
        let comps = Calendar.fromZone(currentTimeZone).dateComponents([.day], from: timeOfDayDatePicker.date)
        let day = comps.day ?? 1
        
        return day > 28 ? "If a month has less than \(day) days, the reminder will occur on the last day of that month." : nil
    }
    
    // MARK: - Setup
    
    func setup(
        forDelegate: DogsAddReminderMonthlyViewDelegate,
        forComponents: MonthlyComponents?,
        forTimeZone: TimeZone
    ) {
        delegate = forDelegate
        currentTimeZone = forTimeZone
        timeOfDayDatePicker.timeZone = forTimeZone
        
        if let components = forComponents {
            let calendar = Calendar.fromZone(currentTimeZone)
            var comps = calendar.dateComponents([.year, .month], from: Date())
            comps.day = components.zonedDay
            comps.hour = components.zonedHour
            comps.minute = components.zonedMinute
            comps.second = 0
            comps.timeZone = forTimeZone
            timeOfDayDatePicker.date = calendar.date(from: comps) ?? timeOfDayDatePicker.date
        }
        updateDescriptionLabel()
    }
    
    // MARK: - Time Zone
    
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
        
        currentTimeZone = newTimeZone
        updateDescriptionLabel()
    }
    
    // MARK: - Functions
    
    private func updateDescriptionLabel() {
        delegate?.didUpdateDescriptionLabel()
        
        rollUnderDisclaimerLabel.text = disclaimerLabelText
        rollUnderDisclaimerLabel.isHidden = disclaimerLabelText == nil
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(stack)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        stack.snp.makeConstraints { make in
            make.edges.equalTo(self.snp.edges)
        }
        
        timeOfDayDatePicker.snp.makeConstraints { make in
            make.height.equalTo(self.snp.width).multipliedBy(Constant.Constraint.Input.megaDatePickerHeightMultiplier)
            make.height.lessThanOrEqualTo(Constant.Constraint.Input.megaDatePickerMaxHeight)
        }
    }
    
}
