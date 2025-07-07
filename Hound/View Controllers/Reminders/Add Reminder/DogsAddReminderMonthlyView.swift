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
        label.text = "A monthly reminder sounds an alarm consistently on the same day each month"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.textColor = .systemGray
        
        return label
    }()
    
    private lazy var timeOfDayDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 260, compressionResistancePriority: 260)
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        
        datePicker.addTarget(self, action: #selector(didUpdateTimeOfDay), for: .valueChanged)
        
        datePicker.date = Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * datePicker.minuteInterval), roundingMethod: .up)
        
        return datePicker
    }()
    
    @objc private func didUpdateTimeOfDay(_ sender: Any) {
        delegate?.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddReminderMonthlyViewDelegate?
    
    // timeOfDayDatePicker.date
    var currentTimeOfDay: Date? {
        timeOfDayDatePicker.date
    }
    
    private var initialTimeOfDay: Date?
    var didUpdateInitialValues: Bool {
        if currentTimeOfDay != initialTimeOfDay {
            return true
        }
        
        return currentTimeOfDay != initialTimeOfDay
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddReminderMonthlyViewDelegate, forTimeOfDay: Date?) {
        delegate = forDelegate
        initialTimeOfDay = forTimeOfDay
        
        timeOfDayDatePicker.date = forTimeOfDay ?? timeOfDayDatePicker.date
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
            monthlyDescriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: ConstraintConstant.Spacing.absoluteVerticalInset),
            monthlyDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            monthlyDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset
            )
        ])
        
        NSLayoutConstraint.activate([
            timeOfDayDatePicker.topAnchor.constraint(equalTo: monthlyDescriptionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            timeOfDayDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            timeOfDayDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            timeOfDayDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVerticalInset
            )
            //            timeOfDayDatePicker.createHeightMultiplier(
            //                ConstraintConstant.Input.datePickerHeightMultiplier,
            //                relativeToWidthOf: view
            //            ),
            //            timeOfDayDatePicker.createMaxHeight(
            //                ConstraintConstant.Input.datePickerMaxHeight
            //            )
        ])
        
    }
    
}
