//
//  SettingsNotificationsAlarmsNotificationSoundsTableViewCellNotificationSoundTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/14/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotificationsAlarmsNotificationSoundsTableViewCellNotificationSoundTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private weak var notificationSoundLabel: GeneralUILabel!

    // MARK: - Properties

    static let cellHeight: CGFloat = 7.5 + 17.5 + 7.5

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    private(set) var isCustomSelected: Bool = false

    // MARK: - Functions

    func setup(forNotificationSound notificationSound: String) {
        notificationSoundLabel.text = notificationSound
    }

    /// isSelected and setSelected are used and modified by the system when a user physically taps on a cell. If we use either of these, this will mess up our own tracking and processes for the selection process
    func setCustomSelectedTableViewCell(_ selected: Bool, animated: Bool) {
        // DO NOT INVOKE DEFAULT IMPLEMENTATION OF super.setSelected(selected, animated: animated)
        guard selected != isCustomSelected else {
            return
        }

        isCustomSelected = selected

        UIView.animate(withDuration: animated ? VisualConstant.AnimationConstant.setCustomSelectedTableViewCell : 0.0) {
            self.contentView.backgroundColor = selected ? .systemBlue : .systemBackground
            self.notificationSoundLabel.textColor = selected ? .systemBackground : .label
        }
    }

}
