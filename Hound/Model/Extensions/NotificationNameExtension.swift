//
//  NotificationNameExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/27/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let didUpdateUserInterfaceStyle = Notification.Name("didUpdateUserInterfaceStyle")
    /// Posted when the user's time zone changes. Views observing this should
    /// refresh any displayed times. The `TimeZoneMonitor` automatically posts
    /// this notification when the system time zone updates, including daylight
    /// savings transitions
    static let didUpdateUserTimeZone = Notification.Name("didUpdateUserTimeZone")
}
