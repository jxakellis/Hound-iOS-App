//
//  DogsMainScreenTableViewCellReminder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/2/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsReminderTVC: HoundTableViewCell {
    
    // TODO TRIGGERS Add special display that a reminder is a trigger result
    // TODO if the name is long enough (e.g. "Fresh Water") is smushed out the recurrance and time of day labels
    
    // MARK: - Elements
    
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = UIColor.systemBackground
        return view
    }()
    
    private let reminderActionIconLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 400, compressionResistancePriority: 400)
        label.textAlignment = .center
        // same as LogTVC
        label.font = UIFont.systemFont(ofSize: 42.5, weight: .medium)
        return label
    }()
    
    private let reminderActionTextLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 390, compressionResistancePriority: 390)
        label.font = Constant.VisualFont.primaryHeaderLabel
        return label
    }()
    
    private lazy var recurrandAndTimeOfDayStack: HoundStackView = {
        let stack = HoundStackView(huggingPriority: 380, compressionResistancePriority: 380)
        stack.addArrangedSubview(recurranceLabel)
        stack.addArrangedSubview(timeOfDayLabel)
        stack.axis = .vertical
        stack.distribution = .fillEqually
        return stack
    }()
    private let recurranceLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 370, compressionResistancePriority: 370)
        label.textAlignment = .right
        label.font = Constant.VisualFont.primaryRegularLabel
        return label
    }()
    private let timeOfDayLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 370, compressionResistancePriority: 370)
        label.textAlignment = .right
        label.font = Constant.VisualFont.primaryRegularLabel
        return label
    }()
    
    private var reminderTextToNextAlarmConstraint: GeneralLayoutConstraint!
    private var nextAlarmRelativeHeightConstraint: NSLayoutConstraint!
    private var nextAlarmZeroHeightConstraint: NSLayoutConstraint!
    private let nextAlarmLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 350, compressionResistancePriority: 350)
        label.backgroundColor = UIColor.secondarySystemBackground
        label.font = Constant.VisualFont.tertiaryRegularLabel
        
        label.shouldRoundCorners = true
        label.staticCornerRadius = nil
        return label
    }()

    private let chevronImageView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 360, compressionResistancePriority: 360)
       
        imageView.alpha = 0.75
        imageView.image = UIImage(systemName: "chevron.right")
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
        
        reminderActionTextLabel.text = forReminder.reminderActionType.convertToReadableName(customActionName: forReminder.reminderCustomActionName)
        reminderActionTextLabel.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        
        recurranceLabel.text = {
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
        recurranceLabel.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        
        timeOfDayLabel.text = {
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
        timeOfDayLabel.alpha = forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha
        
        chevronImageView.alpha = (forReminder.reminderIsEnabled ? reminderEnabledElementAlpha : reminderDisabledElementAlpha) * 0.75
        
        reloadNextAlarmLabel()
    }
    
    // MARK: - Function
    
    func reloadNextAlarmLabel() {
        guard let reminder = reminder else { return }
        
        guard reminder.reminderIsEnabled == true, let executionDate = reminder.reminderExecutionDate else {
            // The reminder is disabled, therefore don't show the next alarm label or padding for it as there is nothing to display
            nextAlarmLabel.isHidden = true
            reminderTextToNextAlarmConstraint.constant = 0
            nextAlarmRelativeHeightConstraint.isActive = false
            nextAlarmZeroHeightConstraint.isActive = true
            return
        }
        
        // Reminder is enabled, therefore show the next alarm label
        nextAlarmLabel.isHidden = false
        reminderTextToNextAlarmConstraint.constant = reminderTextToNextAlarmConstraint.originalConstant
        nextAlarmZeroHeightConstraint.isActive = false
        nextAlarmRelativeHeightConstraint.isActive = true
        
        let nextAlarmHeaderFont = Constant.VisualFont.emphasizedTertiaryRegularLabel
        let nextAlarmBodyFont = Constant.VisualFont.tertiaryRegularLabel
        
        guard Date().distance(to: executionDate) > 0 else {
            nextAlarmLabel.attributedTextClosure = {
                // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
                
                // Add extra spaces at the start and end so the text visually sits properly with its alternative background color and bordered edges
                return NSAttributedString(string: "  No More Time Left  ", attributes: [.font: nextAlarmHeaderFont])
            }
            return
        }
        
        let precalculatedDynamicIsSnoozing = reminder.snoozeComponents.executionInterval != nil
        let precalculatedDynamicText = Date().distance(to: executionDate).readable(capitalizeWords: true, abreviateWords: false)
        
        nextAlarmLabel.attributedTextClosure = {
            // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
            
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

    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(reminderActionIconLabel)
        containerView.addSubview(reminderActionTextLabel)
        containerView.addSubview(recurrandAndTimeOfDayStack)
        containerView.addSubview(chevronImageView)
        containerView.addSubview(nextAlarmLabel)
    }

    override func setupConstraints() {
        super.setupConstraints()
        
        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            // when table view is calculating the height of this view, it might assign a UIView-Encapsulated-Layout-Height which is invalid (too big or too small) for pageSheetHeaderView. This would cause a unresolvable constraints error, causing one of them to break. However, since this is temporary when it calculates the height, we can avoid this .defaultHigh constraint that temporarily turns off
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).withPriority(.defaultHigh),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // reminderActionIconLabel
        NSLayoutConstraint.activate([
            reminderActionIconLabel.topAnchor.constraint(equalTo: reminderActionTextLabel.topAnchor, constant: -Constant.Constraint.Spacing.contentTightIntraHori),
            reminderActionIconLabel.bottomAnchor.constraint(equalTo: reminderActionTextLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentTightIntraHori),
            reminderActionIconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            reminderActionIconLabel.createSquareAspectRatio()
        ])
        
        // reminderActionTextLabel
        NSLayoutConstraint.activate([
            reminderActionTextLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            reminderActionTextLabel.leadingAnchor.constraint(equalTo: reminderActionIconLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            reminderActionTextLabel.createHeightMultiplier(Constant.Constraint.Text.primaryHeaderLabelHeightMultipler, relativeToWidthOf: contentView),
            reminderActionTextLabel.createMaxHeight(Constant.Constraint.Text.primaryHeaderLabelMaxHeight)
        ])
        
        // recurrandAndTimeOfDayStack
        NSLayoutConstraint.activate([
            recurrandAndTimeOfDayStack.leadingAnchor.constraint(equalTo: reminderActionTextLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentTightIntraHori),
            recurrandAndTimeOfDayStack.topAnchor.constraint(equalTo: reminderActionTextLabel.topAnchor),
            recurrandAndTimeOfDayStack.bottomAnchor.constraint(equalTo: reminderActionTextLabel.bottomAnchor)
        ])
        
        // chevronImageView
        NSLayoutConstraint.activate([
            chevronImageView.leadingAnchor.constraint(equalTo: recurrandAndTimeOfDayStack.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.createAspectRatio(Constant.Constraint.Button.chevronAspectRatio),
            chevronImageView.createHeightMultiplier(Constant.Constraint.Button.chevronHeightMultiplier, relativeToWidthOf: contentView),
            chevronImageView.createMaxHeight(Constant.Constraint.Button.chevronMaxHeight)
        ])
        
        // nextAlarmLabel
        reminderTextToNextAlarmConstraint = GeneralLayoutConstraint(reminderActionTextLabel.bottomAnchor.constraint(equalTo: nextAlarmLabel.topAnchor, constant: -Constant.Constraint.Spacing.contentIntraVert))
        nextAlarmRelativeHeightConstraint = nextAlarmLabel.heightAnchor.constraint(equalTo: recurranceLabel.heightAnchor)
        nextAlarmZeroHeightConstraint = nextAlarmLabel.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            reminderTextToNextAlarmConstraint.constraint,
            nextAlarmRelativeHeightConstraint,
            // don't active nextAlarmZeroHeightConstraint
            nextAlarmLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constant.Constraint.Spacing.contentIntraVert),
            nextAlarmLabel.leadingAnchor.constraint(equalTo: reminderActionTextLabel.leadingAnchor),
            nextAlarmLabel.trailingAnchor.constraint(equalTo: recurrandAndTimeOfDayStack.trailingAnchor)
        ])
        
    }

}
