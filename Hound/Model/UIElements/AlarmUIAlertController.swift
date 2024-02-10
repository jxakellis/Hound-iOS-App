//
//  AlarmUIAlertController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/23/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation
import UIKit

final class AlarmUIAlertController: UIAlertController {

    // MARK: - Main

    /// UIAlertController can't be subclassed. Therefore, we can't override the init functions.
    func setup(forDogUUID: UUID, forReminder: Reminder) {
        self.dogUUID = forDogUUID
        self.reminders = [forReminder]
    }

    // MARK: - Properties

    /// If nil, this AlarmUIAlertController has not been combined. If non-nil, this AlarmUIAlertController has been combined into another AlarmUIAlertController.
    private(set) var absorbedIntoAlarmAlertController: AlarmUIAlertController?

    /// The dogUUID that the AlarmUIAlertController is alerting about
    private(set) var dogUUID: UUID?

    /// The reminder(s) that the AlarmUIAlertController is alerting about
    private(set) var reminders: [Reminder]?

    // MARK: - Functions

    /// If the provided AlarmUIAlertController contains matching data, incorporates that data into self and removes the data from the provided AlarmUIAlertController. Returns true if successfully absorbed other view controller.
    func absorb(_ absorbFromAlarmAlertController: AlarmUIAlertController) -> Bool {
        // We don't want to absorb a AlarmUIAlertController that has already been AlarmUIAlertController
        guard absorbFromAlarmAlertController.absorbedIntoAlarmAlertController == nil else {
            return false
        }

        // Check that both AlarmUIAlertController both are setup with reminders
        guard let selfReminder = reminders?.first, let absorbedReminder = absorbFromAlarmAlertController.reminders?.first else {
            return false
        }

        // Check that both AlarmUIAlertController both reference the same dog
        guard let selfDogUUID = dogUUID, let absorbedDogUUID = absorbFromAlarmAlertController.dogUUID, selfDogUUID == absorbedDogUUID else {
            return false
        }

        // Check that both AlarmUIAlertController both reference reminders with the same reminderAction
        guard selfReminder.reminderAction == absorbedReminder.reminderAction  else {
            return false
        }

        // If reminderAction is .custom, check that both AlarmUIAlertController both reference reminders with the same reminderCustomActionName
        guard (selfReminder.reminderAction != .medicine && selfReminder.reminderAction != .custom) || (selfReminder.reminderCustomActionName == absorbedReminder.reminderCustomActionName) else {
            return false
        }

        // Both AlarmUIAlertController are the same. Add their components together
        self.reminders = (self.reminders ?? []) + (absorbFromAlarmAlertController.reminders ?? [])

        // absorbFromAlarmAlertController should now be dismantled
        absorbFromAlarmAlertController.absorbedIntoAlarmAlertController = self
        absorbFromAlarmAlertController.dogUUID = nil
        absorbFromAlarmAlertController.reminders = nil

        return true
    }
}
