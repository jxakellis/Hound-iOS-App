//
//  DogsMainScreenTableViewCellReminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsReminderTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let reminderActionIconLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 370, compressionResistancePriority: 370)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 40, weight: .medium)
        
        label.shouldRoundCorners = true
        label.isRoundingToCircle = true
        return label
    }()
    
    private let reminderActionWithoutIconLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 330, compressionResistancePriority: 330)
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        return label
    }()
    
    private let reminderRecurranceLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 360, compressionResistancePriority: 360)
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private let reminderTimeOfDayBottomConstraintConstant: CGFloat = -5
    private weak var reminderTimeOfDayBottomConstraint: NSLayoutConstraint!
    private let reminderTimeOfDayLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 340, compressionResistancePriority: 340)
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private let reminderNextAlarmHeightConstraintConstant: CGFloat = 25
    private weak var reminderNextAlarmHeightConstraint: NSLayoutConstraint!
    private let reminderNextAlarmLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.backgroundColor = .secondarySystemBackground
        label.font = .systemFont(ofSize: 12.5)
        
        label.shouldRoundCorners = true
        return label
    }()

    private let chevonImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 290, compressionResistancePriority: 290)
       
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray4
        
        return imageView
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "DogsDogTVC"
    
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
        
        reminderActionWithoutIconLabel.text = forReminder.reminderActionType.convertToReadableName(customActionName: forReminder.reminderCustomActionName)
        reminderActionWithoutIconLabel.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        
        reminderRecurranceLabel.text = {
            switch forReminder.reminderType {
            case .countdown:
                return forReminder.countdownComponents.readableRecurranceInterval
            case .weekly:
                return forReminder.weeklyComponents.readableRecurranceInterval
            case .monthly:
                return forReminder.monthlyComponents.readableRecurranceInterval
            case .oneTime:
                return forReminder.oneTimeComponents.readableRecurranceInterval
            }
        }()
        reminderRecurranceLabel.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        
        reminderTimeOfDayLabel.text = {
            switch forReminder.reminderType {
            case .countdown:
                return forReminder.countdownComponents.readableTimeOfDayInterval
            case .weekly:
                return forReminder.weeklyComponents.readableTimeOfDayInterval
            case .monthly:
                return forReminder.monthlyComponents.readableTimeOfDayInterval
            case .oneTime:
                return forReminder.oneTimeComponents.readableTimeOfDayInterval
            }
        }()
        reminderTimeOfDayLabel.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        
        reloadReminderNextAlarmLabel()
        
        chevonImageView.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
    }
    
    // MARK: - Function
    
    func reloadReminderNextAlarmLabel() {
        guard let reminder = reminder else {
            return
        }
        
        guard reminder.reminderIsEnabled == true, let executionDate = reminder.reminderExecutionDate else {
            // The reminder is disabled, therefore don't show the next alarm label or padding for it as there is nothing to display
            reminderNextAlarmLabel.isHidden = true
            reminderTimeOfDayBottomConstraint.constant = 0.0
            reminderNextAlarmHeightConstraint.constant = 0.0
            return
        }
        
        // Reminder is enabled, therefore show the next alarm label
        reminderNextAlarmLabel.isHidden = false
        reminderTimeOfDayBottomConstraint.constant = reminderTimeOfDayBottomConstraintConstant
        reminderNextAlarmHeightConstraint.constant = reminderNextAlarmHeightConstraintConstant
        
        let nextAlarmHeaderFont = UIFont.systemFont(ofSize: reminderNextAlarmLabel.font.pointSize, weight: .semibold)
        let nextAlarmBodyFont = UIFont.systemFont(ofSize: reminderNextAlarmLabel.font.pointSize, weight: .regular)
        
        guard Date().distance(to: executionDate) > 0 else {
            reminderNextAlarmLabel.attributedTextClosure = {
                // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
                
                // Add extra spaces at the start and end so the text visually sits properly with its alternative background color and bordered edges
                return NSAttributedString(string: "  No More Time Left  ", attributes: [.font: nextAlarmHeaderFont])
            }
            return
        }
        
        let precalculatedDynamicIsSnoozing = reminder.snoozeComponents.executionInterval != nil
        let precalculatedDynamicText = Date().distance(to: executionDate).readable(capitalizeWords: true, abreviateWords: false)
        
        reminderNextAlarmLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            
            // Add extra spaces at the start and end so the text visually sits properly with its alternative background color and bordered edges
            let message = NSMutableAttributedString(
                string: precalculatedDynamicIsSnoozing ? "  Finish Snoozing In: " : "  Remind In: ",
                attributes: [.font: nextAlarmHeaderFont]
            )
            
            // Add extra spaces at the start and end so the text visually sits properly with its alternative background color and bordered edges
            message.append(NSAttributedString(string: "\(precalculatedDynamicText)  ", attributes: [.font: nextAlarmBodyFont]))
            
            return message
            
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(reminderActionIconLabel)
        containerView.addSubview(reminderActionWithoutIconLabel)
        containerView.addSubview(reminderRecurranceLabel)
        containerView.addSubview(reminderTimeOfDayLabel)
        containerView.addSubview(reminderNextAlarmLabel)
        containerView.addSubview(chevonImageView)
        
    }

    override func setupConstraints() {
        super.setupConstraints()
        reminderTimeOfDayBottomConstraint = reminderTimeOfDayLabel.bottomAnchor.constraint(equalTo: reminderActionIconLabel.bottomAnchor, constant: reminderTimeOfDayBottomConstraintConstant)
        reminderNextAlarmHeightConstraint = reminderNextAlarmLabel.heightAnchor.constraint(equalToConstant: reminderNextAlarmHeightConstraintConstant)
        
        NSLayoutConstraint.activate([
            reminderActionIconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            reminderActionIconLabel.widthAnchor.constraint(equalToConstant: 50),
            reminderActionIconLabel.widthAnchor.constraint(equalTo: reminderActionIconLabel.heightAnchor),
        
            reminderNextAlarmLabel.topAnchor.constraint(equalTo: reminderTimeOfDayLabel.bottomAnchor, constant: 5),
            reminderNextAlarmLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -7.5),
            reminderNextAlarmLabel.leadingAnchor.constraint(equalTo: reminderActionWithoutIconLabel.leadingAnchor),
            reminderNextAlarmLabel.trailingAnchor.constraint(equalTo: reminderRecurranceLabel.trailingAnchor),
            reminderNextAlarmHeightConstraint,
        
            chevonImageView.leadingAnchor.constraint(equalTo: reminderRecurranceLabel.trailingAnchor, constant: 15),
            chevonImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            chevonImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevonImageView.widthAnchor.constraint(equalTo: chevonImageView.heightAnchor, multiplier: 1 / 1.5),
            chevonImageView.heightAnchor.constraint(equalTo: reminderActionWithoutIconLabel.heightAnchor, multiplier: 30 / 35),
        
            reminderActionWithoutIconLabel.topAnchor.constraint(equalTo: reminderRecurranceLabel.topAnchor, constant: 2.5),
            reminderActionWithoutIconLabel.bottomAnchor.constraint(equalTo: reminderTimeOfDayLabel.bottomAnchor, constant: -2.5),
            reminderActionWithoutIconLabel.leadingAnchor.constraint(equalTo: reminderActionIconLabel.trailingAnchor, constant: 5),
        
            reminderTimeOfDayLabel.topAnchor.constraint(equalTo: reminderRecurranceLabel.bottomAnchor),
            reminderTimeOfDayBottomConstraint,
            reminderTimeOfDayLabel.leadingAnchor.constraint(equalTo: reminderRecurranceLabel.leadingAnchor),
            reminderTimeOfDayLabel.heightAnchor.constraint(equalTo: reminderRecurranceLabel.heightAnchor),
        
            reminderRecurranceLabel.topAnchor.constraint(equalTo: reminderActionIconLabel.topAnchor, constant: 5),
            reminderRecurranceLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 7.5),
            reminderRecurranceLabel.leadingAnchor.constraint(equalTo: reminderActionWithoutIconLabel.trailingAnchor, constant: 10),
            reminderRecurranceLabel.trailingAnchor.constraint(equalTo: reminderTimeOfDayLabel.trailingAnchor),
        
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        
        ])
        
    }
}
