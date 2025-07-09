//
//  DogsAddDogReminderTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogReminderTVCDelegate: AnyObject {
    /// The reminder switch to toggle the enable status was flipped. The reminder was updated and the server was NOT queried.
    func didUpdateReminderIsEnabled(sender: Sender, forReminderUUID: UUID, forReminderIsEnabled: Bool)
}

final class DogsAddDogReminderTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = UIColor.systemBackground
        view.applyStyle(.thinGrayBorder)
        return view
    }()
    
    private let reminderActionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        return label
    }()
    
    private let reminderDisplayableIntervalLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        return label
    }()
    
    private lazy var reminderIsEnabledSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 290, compressionResistancePriority: 290)
        uiSwitch.isOn = true
        uiSwitch.addTarget(self, action: #selector(didToggleReminderIsEnabled), for: .valueChanged)
        return uiSwitch
    }()
    
    private let chevronImageView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 300, compressionResistancePriority: 300)

        imageView.alpha = 0.75
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor.systemGray4
        
        return imageView
    }()
    
    @objc private func didToggleReminderIsEnabled(_ sender: Any) {
        guard let reminderUUID = reminderUUID else {
            return
        }
        
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
        
        let precalculatedReminderActionName = forReminder.reminderActionType.convertToReadableName(customActionName: forReminder.reminderCustomActionName)
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
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            
            return NSMutableAttributedString(
                string: precalculatedReminderActionName,
                attributes: [.font: precalculatedReminderActionFont]
            )
        }
        
        reminderDisplayableIntervalLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            
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
        
        containerView.addSubview(reminderActionLabel)
        containerView.addSubview(reminderIsEnabledSwitch)
        containerView.addSubview(chevronImageView)
        containerView.addSubview(reminderDisplayableIntervalLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            // when table view is calculating the height of this view, it might assign a UIView-Encapsulated-Layout-Height which is invalid (too big or too small) for pageSheetHeaderView. This would cause a unresolvable constraints error, causing one of them to break. However, since this is temporary when it calculates the height, we can avoid this .defaultHigh constraint that temporarily turns off
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).withPriority(.defaultHigh),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        // reminderActionLabel
        NSLayoutConstraint.activate([
            reminderActionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVertInset),
            reminderActionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            reminderActionLabel.trailingAnchor.constraint(equalTo: reminderDisplayableIntervalLabel.trailingAnchor),
            reminderActionLabel.createHeightMultiplier(ConstraintConstant.Text.primaryHeaderLabelHeightMultipler, relativeToWidthOf: contentView),
            reminderActionLabel.createMaxHeight(ConstraintConstant.Text.primaryHeaderLabelMaxHeight)
        ])
        
        // reminderIsEnabledSwitch
        NSLayoutConstraint.activate([
            reminderIsEnabledSwitch.leadingAnchor.constraint(equalTo: reminderActionLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            reminderIsEnabledSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        // chevronImageView
        NSLayoutConstraint.activate([
            chevronImageView.leadingAnchor.constraint(equalTo: reminderIsEnabledSwitch.trailingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.createAspectRatio(ConstraintConstant.Button.chevronAspectRatio),
            chevronImageView.createHeightMultiplier(ConstraintConstant.Button.chevronHeightMultiplier, relativeToWidthOf: contentView),
            chevronImageView.createMaxHeight(ConstraintConstant.Button.chevronMaxHeight)
        ])
        
        // reminderDisplayableIntervalLabel
        NSLayoutConstraint.activate([
            reminderDisplayableIntervalLabel.topAnchor.constraint(equalTo: reminderActionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTightIntraVert),
            reminderDisplayableIntervalLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset),
            reminderDisplayableIntervalLabel.leadingAnchor.constraint(equalTo: reminderActionLabel.leadingAnchor),
            reminderDisplayableIntervalLabel.trailingAnchor.constraint(equalTo: reminderActionLabel.trailingAnchor)
        ])
    }

}
