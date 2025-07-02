//
//  SettingsNotifsAlarmsNotificationSoundTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/14/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsAlarmsNotificationSoundTVC: GeneralUITableViewCell {

    // MARK: - Elements

    private let notificationSoundLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.text = "Notification Sound"
        label.font = VisualConstant.FontConstant.weakSecondaryRegularLabel
        return label
    }()

    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsAlarmsNotificationSoundTVC"

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    private(set) var isCustomSelected: Bool = false
    
    // MARK: - Setup

    func setup(forNotificationSound notificationSound: String) {
        notificationSoundLabel.text = notificationSound
    }
    
    // MARK: - Functions

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelectedTableViewCell(_ selected: Bool, animated: Bool) {
        // DO NOT INVOKE DEFAULT IMPLEMENTATION OF super.setSelected(selected, animated: animated)
        guard selected != isCustomSelected else {
            return
        }

        isCustomSelected = selected

        UIView.animate(withDuration: animated ? VisualConstant.AnimationConstant.toggleSelectUIElement : 0.0) {
            self.contentView.backgroundColor = selected ? .systemBlue : .systemBackground
            self.notificationSoundLabel.textColor = selected ? .systemBackground : .label
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(notificationSoundLabel)
    }

    override func setupConstraints() {
        super.setupConstraints()

        // notificationSoundLabel
        NSLayoutConstraint.activate([
            notificationSoundLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Spacing.contentIntraVertSpacing),
            notificationSoundLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            notificationSoundLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            notificationSoundLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Spacing.contentAbsVertInset)
        ])
    }

}
