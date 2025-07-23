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
    
    @objc private func didUpdateTimeOfDay(_ sender: Any) {
        updateDescriptionLabel()
        delegate?.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddReminderMonthlyViewDelegate?
    
    // timeOfDayDatePicker.date
    var currentTimeOfDay: Date? {
        timeOfDayDatePicker.date
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddReminderMonthlyViewDelegate, forTimeOfDay: Date?) {
        delegate = forDelegate
        timeOfDayDatePicker.date = forTimeOfDay ?? timeOfDayDatePicker.date
        updateDescriptionLabel()
    }
    
    // MARK: - Functions
    
    private func updateDescriptionLabel() {
        // TODO TIMING implement new logic to utilize localization here
        // TODO TIMING add disclaimer if time is 29, 30, or 31 (do we roll over? I forget how we handle that)
        let day = Calendar.current.component(.day, from: timeOfDayDatePicker.date)
        
        // Reminder will go
        monthlyDescriptionLabel.text = "Reminder will sound on the \(day)\(day.daySuffix()) of each month at \(timeOfDayDatePicker.date.formatted(date: .omitted, time: .shortened))"
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(timeOfDayDatePicker)
        addSubview(monthlyDescriptionLabel)
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
            timeOfDayDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            timeOfDayDatePicker.createHeightMultiplier(Constant.Constraint.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            timeOfDayDatePicker.createMaxHeight(Constant.Constraint.Input.megaDatePickerMaxHeight)
        ])
        
    }
    
}
