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
    func didUpdateReminderIsEnabled(sender: Sender, forReminderUUID: UUID, forReminderIsEnabled: Bool)
}

final class DogsAddDogReminderTVC: HoundTableViewCell {
    
    // TODO TRIGGERS add special indicator that this is a reminder from an automation/trigger. the enabled and chevronImageView button should disappear
    
    // MARK: - Elements
    
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = UIColor.systemBackground
        view.applyStyle(.thinGrayBorder)
        return view
    }()
    
    private let reminderActionLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
        return label
    }()
    
    private let reminderDisplayableIntervalLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = VisualConstant.FontConstant.secondaryRegularLabel
        return label
    }()
    
    private lazy var labelStack: HoundStackView = {
        let stack = HoundStackView(huggingPriority: 290, compressionResistancePriority: 290)
        stack.addArrangedSubview(reminderActionLabel)
        stack.addArrangedSubview(reminderDisplayableIntervalLabel)
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = ConstraintConstant.Spacing.contentIntraVert
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
    
    private lazy var chevronSwitchStack: HoundStackView = {
        let stack = HoundStackView(huggingPriority: 300, compressionResistancePriority: 300)
        stack.addArrangedSubview(reminderIsEnabledSwitch)
        stack.addArrangedSubview(chevronImageView)
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = ConstraintConstant.Spacing.absoluteHoriInset
        return stack
    }()
    
    private lazy var finalStack: HoundStackView = {
        let stack = HoundStackView()
        stack.addArrangedSubview(labelStack)
        stack.addArrangedSubview(chevronSwitchStack)
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = ConstraintConstant.Spacing.contentIntraHori
        return stack
    }()
    
    @objc private func didToggleReminderIsEnabled(_ sender: Any) {
        guard let reminderUUID = reminderUUID else { return }
        
        delegate?.didUpdateReminderIsEnabled(sender: Sender(origin: self, localized: self), forReminderUUID: reminderUUID, forReminderIsEnabled: reminderIsEnabledSwitch.isOn)
    }
    
    // MARK: - Properties
    
    static let reuseIdentifier = "DogsAddDogReminderTVC"
    
    private var reminderUUID: UUID?
    
    private weak var delegate: DogsAddDogReminderTVCDelegate?
    
    // MARK: - Setup
    
    func setup(forDelegate: DogsAddDogReminderTVCDelegate, forReminder: Reminder) {
        delegate = forDelegate
        reminderIsEnabledSwitch.isOn = forReminder.reminderIsEnabled
        reminderUUID = forReminder.reminderUUID
        
        if forReminder.reminderIsTriggerResult {
            reminderIsEnabledSwitch.isHidden = true
            chevronImageView.isHidden = true
        }
        
        let precalculatedReminderActionName = forReminder.reminderActionType.convertToReadableName(customActionName: forReminder.reminderCustomActionName, includeMatchingEmoji: true)
        let precalculatedReminderActionFont = self.reminderActionLabel.font ?? UIFont()
        
        let precalculatedReminderDisplayInterval = {
            switch forReminder.reminderType {
            case .countdown:
                return forReminder.countdownComponents.readableInterval
            case .weekly:
                return forReminder.weeklyComponents.readableInterval
            case .monthly:
                return forReminder.monthlyComponents.readableInterval
            case .oneTime:
                return forReminder.oneTimeComponents.readableInterval
            }
        }()
        let precalculatedReminderDisplayIntervalFont = self.reminderDisplayableIntervalLabel.font ?? UIFont()
        
        reminderActionLabel.attributedTextClosure = {
            // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
            
            return NSMutableAttributedString(
                string: precalculatedReminderActionName,
                attributes: [.font: precalculatedReminderActionFont]
            )
        }
        
        reminderDisplayableIntervalLabel.attributedTextClosure = {
            // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
            
            return NSAttributedString(
                string: precalculatedReminderDisplayInterval,
                attributes: [.font: precalculatedReminderDisplayIntervalFont])
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
    
    override func setupConstraints() {
        super.setupConstraints()
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            // Use .high priority to avoid breaking during table view height estimation
            make.bottom.equalTo(contentView.snp.bottom).priority(.high)
            make.leading.equalTo(contentView.snp.leading).offset(ConstraintConstant.Spacing.absoluteHoriInset)
            make.trailing.equalTo(contentView.snp.trailing).inset(ConstraintConstant.Spacing.absoluteHoriInset)
        }
        
        finalStack.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(ConstraintConstant.Spacing.absoluteVertInset)
            make.bottom.equalTo(containerView.snp.bottom).inset(ConstraintConstant.Spacing.absoluteVertInset)
            make.leading.equalTo(containerView.snp.leading).offset(ConstraintConstant.Spacing.contentIntraHori)
            make.trailing.equalTo(containerView.snp.trailing).inset(ConstraintConstant.Spacing.absoluteHoriInset)
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.height.equalTo(contentView.snp.width)
                .multipliedBy(ConstraintConstant.Button.chevronHeightMultiplier)
                .priority(.high)
            make.height.lessThanOrEqualTo(ConstraintConstant.Button.chevronMaxHeight)
            make.width.equalTo(chevronImageView.snp.height)
                .multipliedBy(ConstraintConstant.Button.chevronAspectRatio)
        }
    }

}
