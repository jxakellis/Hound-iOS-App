//
//  DogsAddDogDisplayReminderTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogDisplayReminderTVCDelegate: AnyObject {
    /// The reminder switch to toggle the enable status was flipped. The reminder was updated and the server was NOT queried.
    func didUpdateReminderIsEnabled(sender: Sender, forReminderUUID: UUID, forReminderIsEnabled: Bool)
}

final class DogsAddDogDisplayReminderTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        view.borderColor = .systemGray
        view.borderWidth = 0.5
        view.shouldRoundCorners = true
        return view
    }()
    
    private let reminderActionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        return label
    }()
    
    private let reminderDisplayableIntervalLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private let reminderIsEnabledSwitch: GeneralUISwitch = {
        let uiSwitch = GeneralUISwitch(huggingPriority: 290, compressionResistancePriority: 290)
        uiSwitch.isOn = true
        return uiSwitch
    }()
    
    private let chevonImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 300, compressionResistancePriority: 300)

        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray4
        
        return imageView
    }()
    
    @objc private func didToggleReminderIsEnabled(_ sender: Any) {
        guard let reminderUUID = reminderUUID else {
            return
        }
        
        delegate.didUpdateReminderIsEnabled(sender: Sender(origin: self, localized: self), forReminderUUID: reminderUUID, forReminderIsEnabled: reminderIsEnabledSwitch.isOn)
    }
    
    // MARK: - Properties
    
    static let reuseIdentifier = "DogsDogTVC"
    
    private var reminderUUID: UUID?
    
    private weak var delegate: DogsAddDogDisplayReminderTVCDelegate!
    
    // MARK: - Setup
    
    func setup(forReminder: Reminder) {
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
        reminderIsEnabledSwitch.addTarget(self, action: #selector(didToggleReminderIsEnabled), for: .valueChanged)
        containerView.addSubview(chevonImageView)
        containerView.addSubview(reminderDisplayableIntervalLabel)
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            reminderActionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            reminderActionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            reminderActionLabel.trailingAnchor.constraint(equalTo: reminderDisplayableIntervalLabel.trailingAnchor),
            reminderActionLabel.heightAnchor.constraint(equalToConstant: 35),
            
            chevonImageView.leadingAnchor.constraint(equalTo: reminderIsEnabledSwitch.trailingAnchor, constant: 25),
            chevonImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            chevonImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevonImageView.widthAnchor.constraint(equalToConstant: 20),
            chevonImageView.widthAnchor.constraint(equalTo: chevonImageView.heightAnchor, multiplier: 1 / 1.5),
            
            reminderDisplayableIntervalLabel.topAnchor.constraint(equalTo: reminderActionLabel.bottomAnchor, constant: 2.5),
            reminderDisplayableIntervalLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            reminderDisplayableIntervalLabel.leadingAnchor.constraint(equalTo: reminderActionLabel.leadingAnchor),
            reminderDisplayableIntervalLabel.heightAnchor.constraint(equalToConstant: 20),
            
            reminderIsEnabledSwitch.leadingAnchor.constraint(equalTo: reminderActionLabel.trailingAnchor, constant: 15),
            reminderIsEnabledSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            
        ])
        
    }
}
