//
//  AlarmUIAlertController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/23/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation
import UIKit

final class AlarmUIAlertController: GeneralUIAlertController {
    
    // MARK: - Main
    
    /// UIAlertController can't be subclassed. Therefore, we can't override the init functions.
    func setup(forDogId dogId: Int, forReminder reminder: Reminder) {
        guard hasBeenSetup == false else {
            return
        }
        
        self.referenceAlarmAlertController = self
        self.dogId = dogId
        self.reminders = [reminder]
        self.hasBeenSetup = true
    }
    
    // MARK: - Properties
    
    private(set) var hasBeenSetup = false
    
    /// Reference to the alert controller that the this alertcontroller has been combined with. Self if not combined
    private(set) var referenceAlarmAlertController: AlarmUIAlertController?
    
    /// The dogId that the AlarmUIAlertController is alerting about
    private(set) var dogId: Int?
    
    /// The reminder(s) that the AlarmUIAlertController is alerting about
    private(set) var reminders: [Reminder] = []
    
    // MARK: - Functions
    
    /// Returns true if successfully combined both AlarmUIAlertControllers
    func combine(withAlarmUIAlertController: AlarmUIAlertController) -> Bool {
        // Make sure both of them have been setup,
        guard hasBeenSetup && withAlarmUIAlertController.hasBeenSetup else {
            return false
        }
        
        // Both AlarmUIAlertController have been setup therefore reminders.count >= 1. Note: all reminders in array should have same reminderAction and reminderCustomActionName
        
        let selfReminder = reminders[0]
        let withReminder = withAlarmUIAlertController.reminders[0]
        
        // Make sure self and withAlarmUIAlertController are valid
        guard let selfDogId = dogId, let withDogId = withAlarmUIAlertController.dogId else {
            return false
        }
        
        // dogId and reminderAction always have to match
        guard selfDogId == withDogId && selfReminder.reminderAction == withReminder.reminderAction  else {
            return false
        }
        
        // reminderCustomActionName only has to match if reminderAction is .custom. reminderCustomActionName can be nil.
        guard selfReminder.reminderAction != .custom || (selfReminder.reminderAction == .custom && selfReminder.reminderCustomActionName == withReminder.reminderCustomActionName) else {
            return false
        }
        
        // Verified that alertControllers are the same. Now add together reminderIds. Will allow for self alertController to reset all the reminders and create logs (when an action is selected).
        for reminder in withAlarmUIAlertController.reminders {
            reminders.append(reminder)
        }
        
        withAlarmUIAlertController.referenceAlarmAlertController = self.referenceAlarmAlertController
        return true
    }
}
