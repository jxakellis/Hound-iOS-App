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
    // TODO TIME make any VC or view that use Calendar.user or UserConfiguration.user watch this notification and recalc/reload times when the user time zone changes. However, be careful that this doesn't create an infinite ref, make sure the refs deallocate themselves, similar with weak delegates
    // TODO TIME setup a notification that watches the users device, if the device changes time zones on its own, e.g. when traveling, this notification should be posted
    // TODO TIME if a users device changes from DST/ST just by the natural progression of time, how do we get this notification to trigger. Does timezone.identifier change too or does it stay the same?
    static let didUpdateUserTimeZone = Notification.Name("didUpdateUserTimeZone")
}
