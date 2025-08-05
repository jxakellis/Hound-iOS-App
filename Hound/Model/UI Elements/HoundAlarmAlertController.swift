//
//  HoundAlarmAlertController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/23/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation
import UIKit

final class HoundAlarmAlertController: UIAlertController {
    
    // MARK: - Properties

    /// If nil, this HoundAlarmAlertController has not been combined. If non-nil, this HoundAlarmAlertController has been combined into another HoundAlarmAlertController.
    private(set) var absorbedIntoAlarmAlertController: HoundAlarmAlertController?

    /// The dogUUID that the HoundAlarmAlertController is alerting about
    private(set) var dogUUID: UUID?

    /// The reminder(s) that the HoundAlarmAlertController is alerting about
    private(set) var reminders: [Reminder]?

    // MARK: - Main

    /// UIAlertController can't be subclassed. Therefore, we can't override the init functions.
    func setup(dogUUID: UUID, reminder: Reminder) {
        self.dogUUID = dogUUID
        self.reminders = [reminder]
    }

    // MARK: - Functions

    /// If the provided HoundAlarmAlertController contains matching data, incorporates that data into self and removes the data from the provided HoundAlarmAlertController. Returns true if successfully absorbed other view controller.
    func absorb(_ absorbFromAlarmAlertController: HoundAlarmAlertController) -> Bool {
        // We don't want to absorb a HoundAlarmAlertController that has already been HoundAlarmAlertController
        guard absorbFromAlarmAlertController.absorbedIntoAlarmAlertController == nil else {
            return false
        }

        // Check that both HoundAlarmAlertController both are setup with reminders
        guard let selfReminder = reminders?.first, let absorbedReminder = absorbFromAlarmAlertController.reminders?.first else {
            return false
        }
        
        // Check that both HoundAlarmAlertController both reference the same dog
        guard let selfDogUUID = dogUUID, let absorbedDogUUID = absorbFromAlarmAlertController.dogUUID, selfDogUUID == absorbedDogUUID else {
            return false
        }

        // Check that both HoundAlarmAlertController both reference reminders with the same reminderActionType
        guard selfReminder.reminderActionType == absorbedReminder.reminderActionType  else {
            return false
        }

        // If reminderActionType is .custom, check that both HoundAlarmAlertController both reference reminders with the same reminderCustomActionName
        guard selfReminder.reminderActionType.allowsCustom == false || (selfReminder.reminderCustomActionName == absorbedReminder.reminderCustomActionName) else {
            return false
        }

        // Both HoundAlarmAlertController are the same. Add their components together
        self.reminders = (self.reminders ?? []) + (absorbFromAlarmAlertController.reminders ?? [])

        // absorbFromAlarmAlertController should now be dismantled
        absorbFromAlarmAlertController.absorbedIntoAlarmAlertController = self
        absorbFromAlarmAlertController.dogUUID = nil
        absorbFromAlarmAlertController.reminders = nil

        return true
    }
}
