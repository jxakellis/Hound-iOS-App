//
//  DogsAddDogDisplayReminderTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogDisplayReminderTableViewCellDelegate: AnyObject {
    /// The reminder switch to toggle the enable status was flipped. The reminder was updated and the server was NOT queried.
    func didUpdateReminderIsEnabled(sender: Sender, forReminderUUID: UUID, forReminderIsEnabled: Bool)
}

final class DogsAddDogDisplayReminderTVC: UITableViewCell {
    
    // MARK: - Elements
    
    let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.borderColor = .systemGray
        view.borderWidth = 0.5
        return view
    }()
    
    
    private let reminderActionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(280), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(280), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .vertical)
        label.text = "Potty"
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        return label
    }()
    
    private let reminderDisplayableIntervalLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(270), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(270), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(770), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(770), for: .vertical)
        label.text = "Every 30 Minutes"
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private let reminderIsEnabledSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.contentMode = .scaleToFill
        uiSwitch.setContentHuggingPriority(UILayoutPriority(290), for: .horizontal)
        uiSwitch.setContentHuggingPriority(UILayoutPriority(290), for: .vertical)
        uiSwitch.setContentCompressionResistancePriority(UILayoutPriority(790), for: .horizontal)
        uiSwitch.setContentCompressionResistancePriority(UILayoutPriority(790), for: .vertical)
        uiSwitch.contentHorizontalAlignment = .center
        uiSwitch.contentVerticalAlignment = .center
        uiSwitch.isOn = true
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.onTintColor = .systemBlue
        return uiSwitch
    }()
    
    // MARK: - Additional UI Elements
    private let chevonImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 300, compressionResistancePriority: 800)

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
    
    private var reminderUUID: UUID?
    
    weak var delegate: DogsAddDogDisplayReminderTableViewCellDelegate!
    
    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGeneratedViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGeneratedViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGeneratedViews()
    }
    
    // MARK: - Functions
    
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
    
}

extension DogsAddDogDisplayReminderTVC {
    private func setupGeneratedViews() {
        addSubViews()
        setupConstraints()
    }
    
    private func addSubViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(reminderActionLabel)
        containerView.addSubview(reminderIsEnabledSwitch)
        reminderIsEnabledSwitch.addTarget(self, action: #selector(didToggleReminderIsEnabled), for: .valueChanged)
        containerView.addSubview(chevonImageView)
        containerView.addSubview(reminderDisplayableIntervalLabel)
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            reminderActionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            reminderActionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            reminderActionLabel.trailingAnchor.constraint(equalTo: reminderDisplayableIntervalLabel.trailingAnchor),
            reminderActionLabel.heightAnchor.constraint(equalToConstant: 35),
            
            chevonImageView.leadingAnchor.constraint(equalTo: reminderIsEnabledSwitch.trailingAnchor, constant: 25),
            chevonImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            chevonImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevonImageView.widthAnchor.constraint(equalToConstant: 20),
            chevonImageView.widthAnchor.constraint(equalTo: chevonImageView.heightAnchor, multiplier: 1/1.5),
            
            reminderDisplayableIntervalLabel.topAnchor.constraint(equalTo: reminderActionLabel.bottomAnchor, constant: 2.5),
            reminderDisplayableIntervalLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            reminderDisplayableIntervalLabel.leadingAnchor.constraint(equalTo: reminderActionLabel.leadingAnchor),
            reminderDisplayableIntervalLabel.heightAnchor.constraint(equalToConstant: 20),
            
            reminderIsEnabledSwitch.leadingAnchor.constraint(equalTo: reminderActionLabel.trailingAnchor, constant: 15),
            reminderIsEnabledSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
        ])
        
    }
}
