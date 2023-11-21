//
//  ReminderComponent.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/21/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

protocol ReminderComponent {
    /// The overarching interval that determines when the reminder repeats. For example: the "Every" in "Every 2 hours" or the "Monday" in "Monday at 8:00AM".
    var readableRecurranceInterval: String { get }
    /// The time of day interval that determines when the reminder repeats. For example: the "2 hours" in "Every 2 hours" or the "8:00AM" in "Monday at 8:00AM".
    var readableTimeOfDayInterval: String { get }
    /// The full interval that determines when the reminder repeats: For example: "Every 2 hours" or "Monday at 8:00AM"
    var readableInterval: String { get }
}
