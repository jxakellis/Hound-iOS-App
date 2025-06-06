//
//  SettingsNotificationsAlarmsSnoozeLengthTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotificationsAlarmsSnoozeLengthTableViewCell: UITableViewCell {

    // MARK: - IB

    private let snoozeLengthDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.contentMode = .scaleToFill
        datePicker.setContentHuggingPriority(UILayoutPriority(280), for: .horizontal)
        datePicker.setContentHuggingPriority(UILayoutPriority(280), for: .vertical)
        datePicker.setContentCompressionResistancePriority(UILayoutPriority(780), for: .horizontal)
        datePicker.setContentCompressionResistancePriority(UILayoutPriority(780), for: .vertical)
        datePicker.contentHorizontalAlignment = .center
        datePicker.contentVerticalAlignment = .center
        datePicker.datePickerMode = .countDownTimer
        datePicker.minuteInterval = 1
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    // MARK: - Additional UI Elements
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(290), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(290), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(790), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(790), for: .vertical)
        label.text = "Alarm Snooze"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(270), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(270), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(770), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(770), for: .vertical)
        label.text = "If you snooze an alarm, this is the length of time until it sounds again."
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12.5, weight: .light)
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

    // MARK: - Main
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGeneratedViews()
        synchronizeValues(animated: false)
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGeneratedViews()
        synchronizeValues(animated: false)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupGeneratedViews()
        synchronizeValues(animated: false)
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

}

extension SettingsNotificationsAlarmsSnoozeLengthTableViewCell {
    func setupGeneratedViews() {
        addSubViews()
        setupConstraints()
    }

    func addSubViews() {
        contentView.addSubview(headerLabel)
        contentView.addSubview(snoozeLengthDatePicker)
        contentView.addSubview(descriptionLabel)
        
        snoozeLengthDatePicker.addTarget(self, action: #selector(didUpdateSnoozeLength), for: .valueChanged)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        
            snoozeLengthDatePicker.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 5),
            snoozeLengthDatePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            snoozeLengthDatePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            snoozeLengthDatePicker.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 120/414),
        
            descriptionLabel.topAnchor.constraint(equalTo: snoozeLengthDatePicker.bottomAnchor, constant: 5),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        
        ])
        
    }
}
