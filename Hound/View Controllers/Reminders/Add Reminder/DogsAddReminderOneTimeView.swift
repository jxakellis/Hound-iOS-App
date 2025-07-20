//
//  DogsAddReminderOneTimeVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderOneTimeViewDelegate: AnyObject {
    func willDismissKeyboard()
}

final class DogsAddReminderOneTimeView: HoundView {
    
    // MARK: - Elements
    
    private lazy var oneTimeDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 240, compressionResistancePriority: 260)
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minuteInterval = Constant.Development.reminderMinuteInterval
        
        datePicker.date = Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * datePicker.minuteInterval), roundingMethod: .up)
        
        // they can't choose a one time alarm that isn't in the future, otherwise there is no point
        datePicker.minimumDate = Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * datePicker.minuteInterval), roundingMethod: .up)
        
        datePicker.addTarget(self, action: #selector(didUpdateOneTimeDatePicker), for: .valueChanged)
        
        return datePicker
    }()
    
    private let oneTimeDescriptionLabel: HoundLabel = {
        let label = HoundLabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = Constant.Visual.Font.secondaryRegularLabel
        label.textColor = UIColor.label
        return label
    }()
    
    @objc private func didUpdateOneTimeDatePicker(_ sender: Any) {
        updateDescriptionLabel()
        delegate?.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddReminderOneTimeViewDelegate?
    
    var oneTimeDate: Date? {
        oneTimeDatePicker.date
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddReminderOneTimeViewDelegate, forOneTimeDate: Date?) {
        delegate = forDelegate
        oneTimeDatePicker.date = forOneTimeDate ?? oneTimeDatePicker.date
        updateDescriptionLabel()
    }
    
    // MARK: - Functions
    
    private func updateDescriptionLabel() {
        oneTimeDescriptionLabel.text = "Reminder will sound once on \(oneTimeDatePicker.date.formatted(date: .long, time: .shortened)) then automatically delete"
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        addSubview(oneTimeDatePicker)
        addSubview(oneTimeDescriptionLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // oneTimeDescriptionLabel
        NSLayoutConstraint.activate([
            oneTimeDescriptionLabel.topAnchor.constraint(equalTo: topAnchor),
            oneTimeDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            oneTimeDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // oneTimeDatePicker
        NSLayoutConstraint.activate([
            oneTimeDatePicker.topAnchor.constraint(equalTo: oneTimeDescriptionLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            oneTimeDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            oneTimeDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            oneTimeDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            oneTimeDatePicker.createHeightMultiplier(Constant.Constraint.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            oneTimeDatePicker.createMaxHeight(Constant.Constraint.Input.megaDatePickerMaxHeight)
        ])
    }
    
}
