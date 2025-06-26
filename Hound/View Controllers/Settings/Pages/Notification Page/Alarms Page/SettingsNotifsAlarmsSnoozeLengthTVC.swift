//
//  SettingsNotifsAlarmsSnoozeLengthTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO VERIFY UI
final class SettingsNotifsAlarmsSnoozeLengthTVC: GeneralUITableViewCell {

    // MARK: - Elements

    private let snoozeLengthDatePicker: GeneralUIDatePicker = {
        let datePicker = GeneralUIDatePicker(huggingPriority: 280, compressionResistancePriority: 280)
        datePicker.datePickerMode = .countDownTimer
        return datePicker
    }()
    
    // MARK: - Additional UI Elements
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "Alarm Snooze"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "If you snooze an alarm, this is the length of time until it sounds again."
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
    }()

    @objc private func didUpdateSnoozeLength(_ sender: Any) {
        let beforeUpdateSnoozeLength = UserConfiguration.snoozeLength

        UserConfiguration.snoozeLength = snoozeLengthDatePicker.countDownDuration

        let body = [KeyConstant.userConfigurationSnoozeLength.rawValue: UserConfiguration.snoozeLength]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.snoozeLength = beforeUpdateSnoozeLength
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsAlarmsSnoozeLengthTVC"

    // MARK: - Main
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        synchronizeValues(animated: false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }

    // MARK: - Functions

    /// Updates the displayed isEnabled to reflect the state of isNotificationEnabled stored.
    func synchronizeIsEnabled() {
        snoozeLengthDatePicker.isEnabled = UserConfiguration.isNotificationEnabled
    }

    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()

        snoozeLengthDatePicker.countDownDuration = UserConfiguration.snoozeLength

        // fixes issue with first time datepicker updates not triggering function
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.snoozeLengthDatePicker.countDownDuration = UserConfiguration.snoozeLength
        }
    }
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(snoozeLengthDatePicker)
        contentView.addSubview(descriptionLabel)
        
        snoozeLengthDatePicker.addTarget(self, action: #selector(didUpdateSnoozeLength), for: .valueChanged)
    }

    override func setupConstraints() {
        super.setupConstraints()

        // headerLabel (top)
        let headerLabelTop = headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Global.contentAbsHoriInset)
        let headerLabelLeading = headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentAbsHoriInset)
        let headerLabelTrailing = headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Global.contentAbsHoriInset)

        // snoozeLengthDatePicker (middle)
        let snoozeLengthDatePickerTop = snoozeLengthDatePicker.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 5)
        let snoozeLengthDatePickerLeading = snoozeLengthDatePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentAbsHoriInset)
        let snoozeLengthDatePickerTrailing = snoozeLengthDatePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Global.contentAbsHoriInset)
        let snoozeLengthDatePickerHeight = snoozeLengthDatePicker.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 120.0 / 414.0)

        // descriptionLabel (bottom)
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: snoozeLengthDatePicker.bottomAnchor, constant: 5)
        let descriptionLabelBottom = descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Global.contentAbsHoriInset)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentAbsHoriInset)
        let descriptionLabelTrailing = descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Global.contentAbsHoriInset)

        NSLayoutConstraint.activate([
            // headerLabel
            headerLabelTop,
            headerLabelLeading,
            headerLabelTrailing,

            // snoozeLengthDatePicker
            snoozeLengthDatePickerTop,
            snoozeLengthDatePickerLeading,
            snoozeLengthDatePickerTrailing,
            snoozeLengthDatePickerHeight,

            // descriptionLabel
            descriptionLabelTop,
            descriptionLabelBottom,
            descriptionLabelLeading,
            descriptionLabelTrailing
        ])
    }

}
