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
        label.font = .systemFont(ofSize: 15, weight: .light)
        return label
    }()

    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsAlarmsNotificationSoundTVC"

    private static let topConstraint: CGFloat = 7.5
    private static let heightConstraint: CGFloat = 17.5
    private static let bottomConstraint: CGFloat = 7.5
    static let cellHeight: CGFloat = topConstraint + heightConstraint + bottomConstraint

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

        // notificationSoundLabel constraints
        let notificationSoundLabelTop = notificationSoundLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: SettingsNotifsAlarmsNotificationSoundTVC.topConstraint)
        let notificationSoundLabelBottom = notificationSoundLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -SettingsNotifsAlarmsNotificationSoundTVC.bottomConstraint)
        let notificationSoundLabelLeading = notificationSoundLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        let notificationSoundLabelTrailing = notificationSoundLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        let notificationSoundLabelHeight = notificationSoundLabel.heightAnchor.constraint(equalToConstant: SettingsNotifsAlarmsNotificationSoundTVC.heightConstraint)
        
        NSLayoutConstraint.activate([
            notificationSoundLabelTop,
            notificationSoundLabelBottom,
            notificationSoundLabelLeading,
            notificationSoundLabelTrailing,
            notificationSoundLabelHeight
        ])
    }

}
