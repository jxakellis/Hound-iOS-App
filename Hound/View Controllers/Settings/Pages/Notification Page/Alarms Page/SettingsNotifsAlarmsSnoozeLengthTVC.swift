//
//  SettingsNotifsAlarmsSnoozeLengthTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsAlarmsSnoozeLengthTVC: HoundTableViewCell {

    // MARK: - Elements
    
    private let headerLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "Alarm Snooze"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private lazy var snoozeLengthDatePicker: HoundDatePicker = {
        let datePicker = HoundDatePicker(huggingPriority: 280, compressionResistancePriority: 280)
        datePicker.datePickerMode = .countDownTimer
        datePicker.addTarget(self, action: #selector(didUpdateSnoozeLength), for: .valueChanged)
        return datePicker
    }()
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "If you snooze an alarm, this is the length of time until it sounds again."
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        synchronizeValues(animated: false)
    }
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        synchronizeValues(animated: false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }

    // MARK: - Functions
    
    /// Updates the displayed values to reflect the values stored.
    private func synchronizeValues(animated: Bool) {
        snoozeLengthDatePicker.isEnabled = UserConfiguration.isNotificationEnabled

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
    }

    override func setupConstraints() {
        super.setupConstraints()

        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVertInset),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            headerLabel.createMaxHeight(ConstraintConstant.Text.sectionLabelMaxHeight),
            headerLabel.createHeightMultiplier(ConstraintConstant.Text.sectionLabelHeightMultipler, relativeToWidthOf: contentView)
        ])

        // snoozeLengthDatePicker
        NSLayoutConstraint.activate([
            snoozeLengthDatePicker.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            snoozeLengthDatePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            snoozeLengthDatePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            snoozeLengthDatePicker.createHeightMultiplier(ConstraintConstant.Input.datePickerHeightMultiplier, relativeToWidthOf: contentView),
            snoozeLengthDatePicker.createMaxHeight(ConstraintConstant.Input.datePickerMaxHeight)
        ])

        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: snoozeLengthDatePicker.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset)
        ])
    }

}
