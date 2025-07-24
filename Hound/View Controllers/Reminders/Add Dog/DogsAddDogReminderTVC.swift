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
    
    // TODO REMINDER add tiny 🔕🔔 bell to indicate if individual reminder notifs are on or off
    
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
        return label
    }()
    
    private let intervalLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.secondaryRegularLabel
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
    
    private lazy var chevronSwitchStack: HoundStackView = {
        let stack = HoundStackView(huggingPriority: 300, compressionResistancePriority: 300)
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
        
        triggerResultIndicatorImageView.isHidden = !forReminder.reminderIsTriggerResult
        chevronSwitchStack.isHidden = forReminder.reminderIsTriggerResult
        
        reminderActionLabel.text = forReminder.reminderActionType.convertToReadableName(customActionName: forReminder.reminderCustomActionName, includeMatchingEmoji: true)
        
        intervalLabel.text = {
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
    }

}
