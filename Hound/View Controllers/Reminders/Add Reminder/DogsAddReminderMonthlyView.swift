//
//  DogsAddReminderMonthlyVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/13/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderMonthlyViewDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsAddReminderMonthlyView: HoundView {
    
    // MARK: - Elements
    
    private let monthlyDescriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Constant.Visual.Font.secondaryRegularLabel
        label.textColor = UIColor.label
        
        return label
    }()
    
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
        label.textAlignment = .center
        label.textColor = UIColor.secondaryLabel
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.numberOfLines = 0
        label.isHidden = true
        return label
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
    
    func updateDisplayedTimeZone(from oldTimeZone: TimeZone, to newTimeZone: TimeZone) {
        guard oldTimeZone != newTimeZone else { return }
        
        let calendar = Calendar.fromZone(oldTimeZone)
        let oldComps = calendar.dateComponents([.day, .hour, .minute], from: timeOfDayDatePicker.date)
        let day = oldComps.day ?? 1
        let hour = oldComps.hour ?? 0
        let minute = oldComps.minute ?? 0
        
        let converted = oldTimeZone.convert(
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
        let comps = Calendar.fromZone(currentTimeZone).dateComponents([.day], from: timeOfDayDatePicker.date)
        let day = comps.day ?? 1
        
        rollUnderDisclaimerLabel.text = "If a month has less than \(day) days, the reminder will occur on the last day of that month."
        rollUnderDisclaimerLabel.isHidden = day <= 28
        
        let timeString = timeOfDayDatePicker.date.houndFormatted(
            .formatStyle(date: .omitted, time: .shortened),
            displayTimeZone: currentTimeZone
        )
        
        monthlyDescriptionLabel.text = "Reminder will sound on the \(day)\(day.daySuffix()) of each month at \(timeString)"
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(timeOfDayDatePicker)
        addSubview(monthlyDescriptionLabel)
        addSubview(rollUnderDisclaimerLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // monthlyDescriptionLabel
        NSLayoutConstraint.activate([
            monthlyDescriptionLabel.topAnchor.constraint(equalTo: topAnchor),
            monthlyDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            monthlyDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            timeOfDayDatePicker.topAnchor.constraint(equalTo: monthlyDescriptionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            timeOfDayDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            timeOfDayDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            timeOfDayDatePicker.createHeightMultiplier(Constant.Constraint.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            timeOfDayDatePicker.createMaxHeight(Constant.Constraint.Input.megaDatePickerMaxHeight)
        ])
        
        NSLayoutConstraint.activate([
            rollUnderDisclaimerLabel.topAnchor.constraint(equalTo: timeOfDayDatePicker.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            rollUnderDisclaimerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            rollUnderDisclaimerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            rollUnderDisclaimerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
}
