//
//  DogsAddReminderOneTimeVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/30/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddReminderOneTimeVCDelegate: AnyObject {
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
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.textColor = .systemGray
        return label
    }()
    
    @objc private func didUpdateOneTimeDatePicker(_ sender: Any) {
        delegate?.willDismissKeyboard()
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsAddReminderOneTimeVCDelegate?
    
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
    
    func setup(forDelegate: DogsAddReminderOneTimeVCDelegate, forOneTimeDate: Date?) {
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
            oneTimeDescriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: ConstraintConstant.Spacing.absoluteVerticalInset),
            oneTimeDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            oneTimeDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset
            )
        ])
        
        // oneTimeDatePicker
        NSLayoutConstraint.activate([
            oneTimeDatePicker.topAnchor.constraint(equalTo: oneTimeDescriptionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            oneTimeDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            oneTimeDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            oneTimeDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVerticalInset
            )
            //            oneTimeDatePicker.createHeightMultiplier(
            //                ConstraintConstant.Input.datePickerHeightMultiplier,
            //                relativeToWidthOf: view
            //            ),
            //            oneTimeDatePicker.createMaxHeight(
            //                ConstraintConstant.Input.datePickerMaxHeight
            //            )
        ])
    }
    
}
