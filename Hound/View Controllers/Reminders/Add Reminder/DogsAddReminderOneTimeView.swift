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
        datePicker.minuteInterval = DevelopmentConstant.reminderMinuteInterval
        
        datePicker.date = Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * datePicker.minuteInterval), roundingMethod: .up)
        
        // they can't choose a one time alarm that isn't in the future, otherwise there is no point
        datePicker.minimumDate = Date.roundDate(targetDate: Date(), roundingInterval: Double(60 * datePicker.minuteInterval), roundingMethod: .up)
        
        datePicker.addTarget(self, action: #selector(didUpdateOneTimeDatePicker), for: .valueChanged)
        
        return datePicker
    }()
    
    private let oneTimeDescriptionLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "A single-use reminder sounds one alarm and then automatically deletes"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryRegularLabel
        label.textColor = UIColor.label
        return label
    }()
    
    @objc private func didUpdateOneTimeDatePicker(_ sender: Any) {
        delegate?.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddReminderOneTimeViewDelegate?
    
    var oneTimeDate: Date? {
        oneTimeDatePicker.date
    }
    
    private var initialOneTimeDate: Date?
    var didUpdateInitialValues: Bool {
        if oneTimeDate != initialOneTimeDate {
            return true
        }
        
        return oneTimeDate != initialOneTimeDate
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddReminderOneTimeViewDelegate, forOneTimeDate: Date?) {
        delegate = forDelegate
        initialOneTimeDate = forOneTimeDate
        
        oneTimeDatePicker.date = forOneTimeDate ?? oneTimeDatePicker.date
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
            oneTimeDatePicker.topAnchor.constraint(equalTo: oneTimeDescriptionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            oneTimeDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            oneTimeDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            oneTimeDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            oneTimeDatePicker.createHeightMultiplier(ConstraintConstant.Input.megaDatePickerHeightMultiplier, relativeToWidthOf: self),
            oneTimeDatePicker.createMaxHeight(ConstraintConstant.Input.megaDatePickerMaxHeight)
        ])
    }
    
}
