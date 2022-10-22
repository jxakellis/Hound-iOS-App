//
//  UserConfiguration.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/7/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// Configuration that is local to the app only. If the app is reinstalled then this data should be pulled down from the cloud
enum UserConfiguration {
    /// Sets the UserConfiguration values equal to all the values found in the body. The key for the each body value must match the name of the UserConfiguration property exactly in order to be used. The value must also be able to be converted into the proper data type.
    static func setup(fromBody body: [String: Any]) {
        if let logsInterfaceScaleString = body[KeyConstant.userConfigurationLogsInterfaceScale.rawValue] as? String, let logsInterfaceScale = LogsInterfaceScale(rawValue: logsInterfaceScaleString) {
            self.logsInterfaceScale = logsInterfaceScale
        }
        if let remindersInterfaceScaleString = body[KeyConstant.userConfigurationRemindersInterfaceScale.rawValue] as? String, let remindersInterfaceScale = RemindersInterfaceScale(rawValue: remindersInterfaceScaleString) {
            self.remindersInterfaceScale = remindersInterfaceScale
        }
        if let interfaceStyleInt = body[KeyConstant.userConfigurationInterfaceStyle.rawValue] as? Int, let interfaceStyle = UIUserInterfaceStyle(rawValue: interfaceStyleInt) {
            self.interfaceStyle = interfaceStyle
        }
        if let maximumNumberOfLogsDisplayed = body[KeyConstant.userConfigurationMaximumNumberOfLogsDisplayed.rawValue] as? Int {
            self.maximumNumberOfLogsDisplayed = maximumNumberOfLogsDisplayed
        }
        if let snoozeLength = body[KeyConstant.userConfigurationSnoozeLength.rawValue] as? TimeInterval {
            self.snoozeLength = snoozeLength
        }
        if let isNotificationEnabled = body[KeyConstant.userConfigurationIsNotificationEnabled.rawValue] as? Bool {
            self.isNotificationEnabled = isNotificationEnabled
        }
        if let isLoudNotification = body[KeyConstant.userConfigurationIsLoudNotification.rawValue] as? Bool {
            self.isLoudNotification = isLoudNotification
        }
        if let notificationSoundString = body[KeyConstant.userConfigurationNotificationSound.rawValue] as? String, let notificationSound = NotificationSound(rawValue: notificationSoundString) {
            self.notificationSound = notificationSound
        }
        if let silentModeIsEnabled = body[KeyConstant.userConfigurationSilentModeIsEnabled.rawValue] as? Bool {
            self.silentModeIsEnabled = silentModeIsEnabled
        }
        if let silentModeStartUTCHour = body[KeyConstant.userConfigurationSilentModeStartUTCHour.rawValue] as? Int {
            self.silentModeStartUTCHour = silentModeStartUTCHour
        }
        if let silentModeEndUTCHour = body[KeyConstant.userConfigurationSilentModeEndUTCHour.rawValue] as? Int {
            self.silentModeEndUTCHour = silentModeEndUTCHour
        }
        if let silentModeStartUTCMinute = body[KeyConstant.userConfigurationSilentModeStartUTCMinute.rawValue] as? Int {
            self.silentModeStartUTCMinute = silentModeStartUTCMinute
        }
        if let silentModeEndUTCMinute = body[KeyConstant.userConfigurationSilentModeEndUTCMinute.rawValue] as? Int {
            self.silentModeEndUTCMinute = silentModeEndUTCMinute
        }
    }
    
    // MARK: - In-App Appearance Related
    
    static var logsInterfaceScale: LogsInterfaceScale = .medium
    
    static var remindersInterfaceScale: RemindersInterfaceScale = .medium
    
    static var interfaceStyle: UIUserInterfaceStyle = .unspecified
    
    static var maximumNumberOfLogsDisplayed: Int = 500
    static var maximumNumberOfLogsDisplayedOptions: [Int] = [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000]
    
    // MARK: - Alarm Timing Related
    
    static var snoozeLength: TimeInterval = TimeInterval(60 * 5)
    
    // MARK: - iOS Notification Related
    
    /// This should be stored on the server as it is important to only send notifications to devices that can use them. This will always be overriden by the user upon reinstall if its state is different in that new install.
    static var isNotificationEnabled: Bool = false
    
    /// Determines if the app should send the user loud notifications. Loud notification bypass most iPhone settings to play at max volume (Do Not Disturb, ringer off, volume off...)
    static var isLoudNotification: Bool = false
    
    /// Sound a notification will play
    static var notificationSound: NotificationSound = NotificationSound.radar
    
    static var silentModeIsEnabled: Bool = false
    
    /// Hour of the day, in UTC, that silent mode will start. During silent mode, no notifications will be sent to the user
    static var silentModeStartUTCHour: Int = {
        // We want hour 22 of the day in the users local timezone (10:__ PM)
        let defaultUTCHour = 22
        let hoursFromUTC = Calendar.localCalendar.timeZone.secondsFromGMT() / 3600
        
        // UTCHour + hoursFromUTC = localHour
        // UTCHour = localHour - hoursFromUTC
        
        var localHour = defaultUTCHour - hoursFromUTC
        // localHour could be negative, so roll over into positive
        localHour += 24
        // Make sure localHour [0, 23]
        localHour = localHour % 24
        
        return localHour
    }()
    
    /// Hour of the day, in UTC, that silent mode will end. During silent mode, no notifications will be sent to the user
    static var silentModeEndUTCHour: Int = {
        // We want hour 5 of the day in the users local timezone (5:__ AM)
        let defaultUTCHour = 5
        let hoursFromUTC = Calendar.localCalendar.timeZone.secondsFromGMT() / 3600
        
        // UTCHour + hoursFromUTC = localHour
        // UTCHour = localHour - hoursFromUTC
        
        var localHour = defaultUTCHour - hoursFromUTC
        // localHour could be negative, so roll over into positive
        localHour += 24
        // Make sure localHour [0, 23]
        localHour = localHour % 24
        
        return localHour
    }()
    
    static var silentModeStartUTCMinute: Int = {
        // We want minute 0 of the day in the users local timezone (_:?? AM)
        let defaultUTCMinute = 0
        let minutesFromUTC = (Calendar.localCalendar.timeZone.secondsFromGMT() % 3600) / 60
        
        // UTCMinute + minuteFromUTC = localMinute
        // UTCMinute = localMinute - minuteFromUTC
        
        var localMinute = defaultUTCMinute - minutesFromUTC
        // localMinute could be negative, so roll over into positive
        localMinute += 60
        // Make sure localMinute [0, 59]
        localMinute = localMinute % 60
        
        return localMinute
    }()
    
    static var silentModeEndUTCMinute: Int = {
        // We want minute 0 of the day in the users local timezone (_:?? AM)
        let defaultUTCMinute = 0
        let minutesFromUTC = (Calendar.localCalendar.timeZone.secondsFromGMT() % 3600) / 60
        
        // UTCMinute + minuteFromUTC = localMinute
        // UTCMinute = localMinute - minuteFromUTC
        
        var localMinute = defaultUTCMinute - minutesFromUTC
        // localMinute could be negative, so roll over into positive
        localMinute += 60
        // Make sure localMinute [0, 59]
        localMinute = localMinute % 60
        
        return localMinute
    }()
}

extension UserConfiguration {
    // MARK: - Request
    
    /// Returns an array literal of the user configurations's properties. This is suitable to be used as the JSON body for a HTTP request
    static func createBody(addingOntoBody body: [String: Any]?) -> [String: Any] {
        var body: [String: Any] = body ?? [:]
        body[KeyConstant.userConfigurationLogsInterfaceScale.rawValue] = UserConfiguration.logsInterfaceScale.rawValue
        body[KeyConstant.userConfigurationRemindersInterfaceScale.rawValue] = UserConfiguration.remindersInterfaceScale.rawValue
        body[KeyConstant.userConfigurationInterfaceStyle.rawValue] = UserConfiguration.interfaceStyle.rawValue
        body[KeyConstant.userConfigurationMaximumNumberOfLogsDisplayed.rawValue] = UserConfiguration.maximumNumberOfLogsDisplayed
        body[KeyConstant.userConfigurationSnoozeLength.rawValue] = UserConfiguration.snoozeLength
        body[KeyConstant.userConfigurationIsNotificationEnabled.rawValue] = UserConfiguration.isNotificationEnabled
        body[KeyConstant.userConfigurationIsLoudNotification.rawValue] = UserConfiguration.isLoudNotification
        body[KeyConstant.userConfigurationNotificationSound.rawValue] = UserConfiguration.notificationSound.rawValue
        
        body[KeyConstant.userConfigurationSilentModeIsEnabled.rawValue] = UserConfiguration.silentModeIsEnabled
        body[KeyConstant.userConfigurationSilentModeStartUTCHour.rawValue] = UserConfiguration.silentModeStartUTCHour
        body[KeyConstant.userConfigurationSilentModeEndUTCHour.rawValue] = UserConfiguration.silentModeEndUTCHour
        body[KeyConstant.userConfigurationSilentModeStartUTCMinute.rawValue] = UserConfiguration.silentModeStartUTCMinute
        body[KeyConstant.userConfigurationSilentModeEndUTCMinute.rawValue] = UserConfiguration.silentModeEndUTCMinute
        return body
    }
}
