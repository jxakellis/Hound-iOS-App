//
//  DogsMainScreenTableViewCellReminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

final class DogsReminderTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = UIColor.systemBackground
        return view
    }()
    
    private let reminderActionIconLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.textAlignment = .center
        // same as LogTVC
        label.font = UIFont.systemFont(ofSize: 42.5, weight: .medium)
        return label
    }()
    private let triggerResultIndicatorImageView: HoundImageView = {
        let imageView = HoundImageView()
        imageView.image = UIImage(systemName: "sparkles")
        imageView.tintColor = UIColor.systemBlue
        return imageView
    }()
    
    private let reminderActionTextLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.primaryHeaderLabel
        return label
    }()
    
    private let intervalLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.secondaryRegularLabel
        return label
    }()
    
    private let nextAlarmLabel: HoundLabel = {
        let label = HoundLabel()
        label.backgroundColor = UIColor.secondarySystemBackground
        // font set in attributed text closure
        label.shouldInsetText = true
        
        label.shouldRoundCorners = true
        label.staticCornerRadius = nil
        return label
    }()
    
    private lazy var nestedLabelStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(reminderActionTextLabel)
        stack.addArrangedSubview(intervalLabel)
        stack.axis = .vertical
        stack.spacing = Constant.Constraint.Spacing.contentTightIntraVert
        return stack
    }()
    private lazy var labelStack: HoundStackView = {
        let stack = HoundStackView(huggingPriority: 280, compressionResistancePriority: 280)
        stack.addArrangedSubview(nestedLabelStack)
        stack.addArrangedSubview(nextAlarmLabel)
        stack.axis = .vertical
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        return stack
    }()

    private let chevronImageView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 300, compressionResistancePriority: 300)
       
        imageView.alpha = 0.75
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor.systemGray4
        
        return imageView
    }()
    
    private let notificationBellImageView: HoundImageView = {
        let imageView = HoundImageView()
        
        imageView.image = UIImage(systemName: "bell.slash")
        imageView.tintColor = UIColor.systemGray4
        
        return imageView
    }()
    
    private let timeZoneIndicatorImageView: HoundImageView = {
            let imageView = HoundImageView()

            imageView.image = UIImage(systemName: "globe")
            imageView.tintColor = UIColor.systemGray4

            return imageView
        }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "DogsReminderTVC"
    
    var dogUUID: UUID?
    var reminder: Reminder?
    
    private let reminderEnabledElementAlpha: CGFloat = 1.0
    private let reminderDisabledElementAlpha: CGFloat = 0.4
    
    // MARK: - Setup
    
    // Setup function that sets up the different IBOutlet properties
    func setup(forDogUUID: UUID, forReminder: Reminder) {
        self.dogUUID = forDogUUID
        self.reminder = forReminder
        
        reminderActionIconLabel.text = forReminder.reminderActionType.emoji
        reminderActionIconLabel.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        reminderActionIconLabel.isHidden = forReminder.reminderIsTriggerResult
        
        triggerResultIndicatorImageView.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        triggerResultIndicatorImageView.isHidden = !forReminder.reminderIsTriggerResult
        
        reminderActionTextLabel.text = forReminder.reminderActionType.convertToReadableName(customActionName: forReminder.reminderCustomActionName)
        reminderActionTextLabel.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        
        intervalLabel.text = forReminder.readableRecurrance()
        intervalLabel.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        
        chevronImageView.alpha = (forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha) * 0.75
        notificationBellImageView.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        
        let reminderEnabled = forReminder.reminderIsEnabled
        let userIsRecipient = forReminder.reminderRecipientUserIds.contains { $0 == UserInformation.userId ?? Constant.Visual.Text.unknownUserId }
        let hasRecipients = !forReminder.reminderRecipientUserIds.isEmpty
        
        let shouldShowBell =
        reminderEnabled && (
            !userIsRecipient ||
            (hasRecipients && !UserConfiguration.isNotificationEnabled) ||
            (hasRecipients && !UserConfiguration.isReminderNotificationEnabled)
        )
        
        notificationBellImageView.isHidden = !shouldShowBell
        timeZoneIndicatorImageView.isHidden = !forReminder.reminderIsEnabled || UserConfiguration.timeZone == forReminder.reminderTimeZone
        
        reloadNextAlarmLabel()
    }
    
    // MARK: - Function
    
    func reloadNextAlarmLabel() {
        guard let reminder = reminder else { return }
        
        guard reminder.reminderIsEnabled == true, let executionDate = reminder.reminderExecutionDate else {
            nextAlarmLabel.isHidden = true
            return
        }
        
        nextAlarmLabel.isHidden = false
        
        let nextAlarmHeaderFont = Constant.Visual.Font.emphasizedSecondaryRegularLabel
        let nextAlarmBodyFont = Constant.Visual.Font.secondaryRegularLabel
        
        guard Date().distance(to: executionDate) > 0 else {
            nextAlarmLabel.attributedTextClosure = {
                // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
                return NSAttributedString(string: "No More Time Left", attributes: [.font: nextAlarmHeaderFont])
            }
            return
        }
        
        let precalculatedDynamicIsSnoozing = reminder.snoozeComponents.executionInterval != nil
        let precalculatedDynamicText = Date().distance(to: executionDate).readable(capitalizeWords: false, abbreviationLevel: .short, maxComponents: 2)
        
        nextAlarmLabel.attributedTextClosure = {
            // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
            
            let message = NSMutableAttributedString(
                string: precalculatedDynamicIsSnoozing ? "Finish Snoozing In: " : "Remind In: ",
                attributes: [.font: nextAlarmHeaderFont]
            )
            
            message.append(NSAttributedString(string: precalculatedDynamicText, attributes: [.font: nextAlarmBodyFont]))
            
            return message
            
        }
    }
    
    // MARK: - Setup Elements

    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(reminderActionIconLabel)
        containerView.addSubview(triggerResultIndicatorImageView)
        containerView.addSubview(labelStack)
        containerView.addSubview(chevronImageView)
        containerView.addSubview(notificationBellImageView)
        containerView.addSubview(timeZoneIndicatorImageView)
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
        
        reminderActionIconLabel.snp.makeConstraints { make in
            make.top.equalTo(labelStack.snp.top).inset(Constant.Constraint.Spacing.contentTightIntraHori)
            make.leading.equalTo(containerView.snp.leading).offset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.height.equalTo(reminderActionIconLabel.snp.width)
        }
        
        triggerResultIndicatorImageView.snp.makeConstraints { make in
            make.top.equalTo(reminderActionIconLabel.snp.top).offset(Constant.Constraint.Spacing.contentTightIntraHori)
            make.bottom.equalTo(reminderActionIconLabel.snp.bottom).inset(Constant.Constraint.Spacing.contentTightIntraHori)
            make.leading.equalTo(reminderActionIconLabel.snp.leading).offset(Constant.Constraint.Spacing.contentTightIntraHori)
            make.trailing.equalTo(reminderActionIconLabel.snp.trailing).inset(Constant.Constraint.Spacing.contentTightIntraHori)
        }
        
        labelStack.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(Constant.Constraint.Spacing.absoluteVertInset)
            make.bottom.equalTo(containerView.snp.bottom).inset(Constant.Constraint.Spacing.absoluteVertInset)
            make.leading.equalTo(reminderActionIconLabel.snp.trailing).offset(Constant.Constraint.Spacing.contentIntraHori)
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.leading.equalTo(labelStack.snp.trailing).offset(Constant.Constraint.Spacing.contentIntraHori)
            make.trailing.equalTo(containerView.snp.trailing).inset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.centerY.equalTo(containerView.snp.centerY)
            make.height.equalTo(contentView.snp.width).multipliedBy(Constant.Constraint.Button.chevronHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Button.chevronMaxHeight)
            make.width.equalTo(chevronImageView.snp.height).multipliedBy(Constant.Constraint.Button.chevronAspectRatio)
        }
        
        notificationBellImageView.snp.makeConstraints { make in
            make.centerX.equalTo(chevronImageView.snp.centerX)
            make.centerY.equalTo(reminderActionTextLabel.snp.centerY)
            make.height.equalTo(chevronImageView.snp.height)
            make.width.equalTo(notificationBellImageView.snp.height)
        }
        
        timeZoneIndicatorImageView.snp.makeConstraints { make in
            make.centerX.equalTo(chevronImageView.snp.centerX)
            make.centerY.equalTo(nextAlarmLabel.snp.centerY)
            make.height.equalTo(chevronImageView.snp.height)
            make.width.equalTo(timeZoneIndicatorImageView.snp.height)
        }
    }

}
