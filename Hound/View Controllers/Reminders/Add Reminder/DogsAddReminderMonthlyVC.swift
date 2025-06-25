//
//  DogsAddReminderMonthlyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/13/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderMonthlyViewControllerDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsAddReminderMonthlyViewController: GeneralUIViewController {

    // MARK: - Elements

    private let timeOfDayDatePicker: GeneralUIDatePicker = {
        let datePicker = GeneralUIDatePicker(huggingPriority: 260, compressionResistancePriority: 260)
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        
        return datePicker
    }()
    
    // MARK: - Additional UI Elements
    private let monthlyDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "A monthly reminder sounds an alarm consistently on the same day each month"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.regularLabel
        label.textColor = .systemGray
        
        return label
    }()

    @objc private func didUpdateTimeOfDay(_ sender: Any) {
        delegate?.willDismissKeyboard()
    }

    // MARK: - Properties

    private weak var delegate: DogsAddReminderMonthlyViewControllerDelegate?

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

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeOfDayDatePicker.date = initialTimeOfDay ?? Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * timeOfDayDatePicker.minuteInterval), roundingMethod: .up)
        initialTimeOfDay = timeOfDayDatePicker.date

        // fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.timeOfDayDatePicker.date = self.timeOfDayDatePicker.date
        }
    }

    // MARK: - Setup

    func setup(forDelegate: DogsAddReminderMonthlyViewControllerDelegate, forTimeOfDay: Date?) {
        delegate = forDelegate
        initialTimeOfDay = forTimeOfDay
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        view.addSubview(timeOfDayDatePicker)
        timeOfDayDatePicker.addTarget(self, action: #selector(didUpdateTimeOfDay), for: .valueChanged)
        view.addSubview(monthlyDescriptionLabel)
        
    }

    override func setupConstraints() {
        super.setupConstraints()

        // timeOfDayDatePicker
        let timeOfDayDatePickerTop = timeOfDayDatePicker.topAnchor.constraint(equalTo: monthlyDescriptionLabel.bottomAnchor, constant: 10)
        let timeOfDayDatePickerBottom = timeOfDayDatePicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        let timeOfDayDatePickerLeading = timeOfDayDatePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        let timeOfDayDatePickerTrailing = timeOfDayDatePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)

        // monthlyDescriptionLabel
        let monthlyDescriptionLabelTop = monthlyDescriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        let monthlyDescriptionLabelLeading = monthlyDescriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        let monthlyDescriptionLabelTrailing = monthlyDescriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)

        NSLayoutConstraint.activate([
            // timeOfDayDatePicker
            timeOfDayDatePickerTop,
            timeOfDayDatePickerBottom,
            timeOfDayDatePickerLeading,
            timeOfDayDatePickerTrailing,

            // monthlyDescriptionLabel
            monthlyDescriptionLabelTop,
            monthlyDescriptionLabelLeading,
            monthlyDescriptionLabelTrailing
        ])
    }

}
