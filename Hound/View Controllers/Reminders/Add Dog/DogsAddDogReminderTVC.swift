//
//  DogsAddDogReminderTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

protocol DogsAddDogReminderTVCDelegate: AnyObject {
    /// The reminder switch to toggle the enable status was flipped. The reminder was updated and the server was NOT queried.
    func didUpdateReminderIsEnabled(sender: Sender, reminderUUID: UUID, reminderIsEnabled: Bool)
}

final class DogsAddDogReminderTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = UIColor.systemBackground
        view.applyStyle(.thinGrayBorder)
        return view
    }()
    
    private let triggerResultIndicatorImageView: HoundImageView = {
        let imageView = HoundImageView()
        imageView.image = UIImage(systemName: "sparkles")
        imageView.tintColor = UIColor.systemBlue
        return imageView
    }()
    
    private let reminderActionLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.emphasizedPrimaryRegularLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    
    private let intervalLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.secondaryRegularLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    
    private lazy var labelStack: HoundStackView = {
        let stack = HoundStackView(huggingPriority: 290, compressionResistancePriority: 290)
        stack.addArrangedSubview(reminderActionLabel)
        stack.addArrangedSubview(intervalLabel)
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var reminderIsEnabledSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch()
        uiSwitch.isOn = true
        uiSwitch.addTarget(self, action: #selector(didToggleReminderIsEnabled), for: .valueChanged)
        return uiSwitch
    }()
    
    private let chevronImageView: HoundImageView = {
        let imageView = HoundImageView()
        
        imageView.alpha = 0.75
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor.systemGray4
        
        return imageView
    }()
    
    private let noNotificationIndicator: HoundImageView = {
        let imageView = HoundImageView()
        
        imageView.image = UIImage(systemName: "bell.slash")
        imageView.tintColor = UIColor.systemGray4
        
        return imageView
    }()
    
    private let differentTimeZoneIndicator: HoundImageView = {
        let imageView = HoundImageView()
        
        imageView.image = UIImage(systemName: "globe")
        imageView.tintColor = UIColor.systemGray4
        
        return imageView
    }()
    
    private lazy var chevronSwitchStack: HoundStackView = {
        let stack = HoundStackView(huggingPriority: 300, compressionResistancePriority: 300)
        
        let imageStack = HoundStackView()
        imageStack.addArrangedSubview(noNotificationIndicator)
        imageStack.addArrangedSubview(differentTimeZoneIndicator)
        imageStack.axis = .vertical
        imageStack.alignment = .trailing
        imageStack.spacing = Constant.Constraint.Spacing.contentIntraVert
        
        stack.addArrangedSubview(imageStack)
        stack.addArrangedSubview(reminderIsEnabledSwitch)
        stack.addArrangedSubview(chevronImageView)
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = Constant.Constraint.Spacing.absoluteHoriInset
        return stack
    }()
    
    private lazy var finalStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(triggerResultIndicatorImageView)
        stack.addArrangedSubview(labelStack)
        stack.addArrangedSubview(chevronSwitchStack)
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = Constant.Constraint.Spacing.contentIntraHori
        return stack
    }()
    
    @objc private func didToggleReminderIsEnabled(_ sender: Any) {
        guard let reminder = reminder else { return }
        
        reminder.reminderIsEnabled = reminderIsEnabledSwitch.isOn
        updateIndicators()
        
        delegate?.didUpdateReminderIsEnabled(sender: Sender(origin: self, localized: self), reminderUUID: reminder.reminderUUID, reminderIsEnabled: reminderIsEnabledSwitch.isOn)
    }
    
    // MARK: - Properties
    
    static let reuseIdentifier = "DogsAddDogReminderTVC"
    
    private var reminder: Reminder?
    
    private weak var delegate: DogsAddDogReminderTVCDelegate?
    
    // MARK: - Setup
    
    func setup(delegate: DogsAddDogReminderTVCDelegate, reminder: Reminder) {
        self.delegate = delegate
        reminderIsEnabledSwitch.isOn = reminder.reminderIsEnabled
        self.reminder = reminder
        
        reminderActionLabel.text = reminder.reminderActionType.convertToReadableName(customActionName: reminder.reminderCustomActionName, includeMatchingEmoji: true)
        
        intervalLabel.text = reminder.readableRecurrance()
        
        triggerResultIndicatorImageView.isHidden = !reminder.reminderIsTriggerResult
        chevronImageView.isHidden = reminder.reminderIsTriggerResult
        reminderIsEnabledSwitch.isHidden = reminder.reminderIsTriggerResult
        
        updateIndicators()
    }
    
    // MARK: - Functions
    
    private func updateIndicators() {
        guard let reminder = reminder else { return }
        let userIsRecipient = reminder.reminderRecipientUserIds.contains { $0 == UserInformation.userId ?? Constant.Visual.Text.unknownUserId }
        let hasRecipients = !reminder.reminderRecipientUserIds.isEmpty
        
        let shouldShowBell =
        reminder.reminderIsEnabled && (
            !userIsRecipient ||
            (hasRecipients && !UserConfiguration.isNotificationEnabled) ||
            (hasRecipients && !UserConfiguration.isReminderNotificationEnabled)
        )
        if noNotificationIndicator.isHidden != !shouldShowBell {
            noNotificationIndicator.isHidden = !shouldShowBell
            remakeNoNotificationIndicatorConstraints()
        }
        
        let shouldShowDiffTZ = reminder.reminderIsEnabled && reminder.reminderTimeZone != UserConfiguration.timeZone
        if differentTimeZoneIndicator.isHidden != !shouldShowDiffTZ {
            differentTimeZoneIndicator.isHidden = !shouldShowDiffTZ
            remakeDifferentTimeZoneIndicatorConstraints()
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        
        containerView.addSubview(finalStack)
    }
    
    private func remakeNoNotificationIndicatorConstraints() {
        noNotificationIndicator.snp.remakeConstraints { make in
            // the entire ui becomes unresponsive if we dont do these 0 constraints
            if noNotificationIndicator.isHidden {
                make.height.equalTo(0)
                make.width.equalTo(0)
            }
            else {
                make.height.equalTo(contentView.snp.width).multipliedBy(Constant.Constraint.Button.chevronHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(Constant.Constraint.Button.chevronMaxHeight)
                make.width.equalTo(noNotificationIndicator.snp.height)
            }
        }
    }
    
    private func remakeDifferentTimeZoneIndicatorConstraints() {
        differentTimeZoneIndicator.snp.remakeConstraints { make in
            // the entire ui becomes unresponsive if we dont do these 0 constraints
            if differentTimeZoneIndicator.isHidden {
                make.height.equalTo(0)
                make.width.equalTo(0)
            }
            else {
                make.height.equalTo(contentView.snp.width).multipliedBy(Constant.Constraint.Button.chevronHeightMultiplier).priority(.high)
                make.height.lessThanOrEqualTo(Constant.Constraint.Button.chevronMaxHeight)
                make.width.equalTo(differentTimeZoneIndicator.snp.height)
            }
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            // Use .high priority to avoid breaking during table view height estimation
            make.bottom.equalTo(contentView.snp.bottom).priority(.high)
            make.leading.equalTo(contentView.snp.leading).offset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.trailing.equalTo(contentView.snp.trailing).inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        
        finalStack.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(Constant.Constraint.Spacing.absoluteVertInset)
            make.bottom.equalTo(containerView.snp.bottom).inset(Constant.Constraint.Spacing.absoluteVertInset)
            make.leading.equalTo(containerView.snp.leading).offset(Constant.Constraint.Spacing.contentIntraHori)
            make.trailing.equalTo(containerView.snp.trailing).inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        
        triggerResultIndicatorImageView.snp.makeConstraints { make in
            make.height.equalTo(contentView.snp.width).multipliedBy(Constant.Constraint.Button.miniCircleHeightMultiplier / 1.5).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Button.miniCircleMaxHeight / 1.5)
            make.width.equalTo(triggerResultIndicatorImageView.snp.height)
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.height.equalTo(contentView.snp.width).multipliedBy(Constant.Constraint.Button.chevronHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Button.chevronMaxHeight)
            make.width.equalTo(chevronImageView.snp.height).multipliedBy(Constant.Constraint.Button.chevronAspectRatio)
        }
        
        remakeNoNotificationIndicatorConstraints()
        remakeDifferentTimeZoneIndicatorConstraints()
    }
    
}
