//
//  UserConfiguration.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/7/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// Configuration that is local to the app only. If the app is reinstalled then this data should be pulled down from the cloud
final class UserConfiguration: UserDefaultPersistable {
    
    // MARK: - UserDefaultPersistable
    
    static func persist(toUserDefaults: UserDefaults) {
        toUserDefaults.set(UserConfiguration.interfaceStyle.rawValue, forKey: Constant.Key.userConfigurationInterfaceStyle.rawValue)
        toUserDefaults.set(UserConfiguration.measurementSystem.rawValue, forKey: Constant.Key.userConfigurationMeasurementSystem.rawValue)
        
        toUserDefaults.set(UserConfiguration.notificationSound.rawValue, forKey: Constant.Key.userConfigurationNotificationSound.rawValue)
        
        toUserDefaults.set(UserConfiguration.isNotificationEnabled, forKey: Constant.Key.userConfigurationIsNotificationEnabled.rawValue)
        toUserDefaults.set(UserConfiguration.isLoudNotificationEnabled, forKey: Constant.Key.userConfigurationIsLoudNotificationEnabled.rawValue)
        toUserDefaults.set(UserConfiguration.isLogNotificationEnabled, forKey: Constant.Key.userConfigurationIsLogNotificationEnabled.rawValue)
        toUserDefaults.set(UserConfiguration.isReminderNotificationEnabled, forKey: Constant.Key.userConfigurationIsReminderNotificationEnabled.rawValue)
        
        toUserDefaults.set(UserConfiguration.isSilentModeEnabled, forKey: Constant.Key.userConfigurationIsSilentModeEnabled.rawValue)
        toUserDefaults.set(UserConfiguration.silentModeStartUTCHour, forKey: Constant.Key.userConfigurationSilentModeStartUTCHour.rawValue)
        toUserDefaults.set(UserConfiguration.silentModeEndUTCHour, forKey: Constant.Key.userConfigurationSilentModeEndUTCHour.rawValue)
        toUserDefaults.set(UserConfiguration.silentModeStartUTCMinute, forKey: Constant.Key.userConfigurationSilentModeStartUTCMinute.rawValue)
        toUserDefaults.set(UserConfiguration.silentModeEndUTCMinute, forKey: Constant.Key.userConfigurationSilentModeEndUTCMinute.rawValue)
    }
    
    static func load(fromUserDefaults: UserDefaults) {
        // NOTE: User Configuration is stored on the Hound server and retrieved synced. However, if the user is in offline mode, they will need these values. Therefore, use local storage as a second backup for these values
        
        if let interfaceStyleInt = fromUserDefaults.value(forKey: Constant.Key.userConfigurationInterfaceStyle.rawValue) as? Int {
            UserConfiguration.interfaceStyle = UIUserInterfaceStyle(rawValue: interfaceStyleInt) ?? UserConfiguration.interfaceStyle
        }
        if let measurementSystemInt = fromUserDefaults.value(forKey: Constant.Key.userConfigurationMeasurementSystem.rawValue) as? Int {
            UserConfiguration.measurementSystem = MeasurementSystem(rawValue: measurementSystemInt) ?? UserConfiguration.measurementSystem
        }
        
        UserConfiguration.snoozeLength = fromUserDefaults.value(forKey: Constant.Key.userConfigurationSnoozeLength.rawValue) as? Double ?? UserConfiguration.snoozeLength
        
        UserConfiguration.isNotificationEnabled = fromUserDefaults.value(forKey: Constant.Key.userConfigurationIsNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isNotificationEnabled
        UserConfiguration.isLoudNotificationEnabled = fromUserDefaults.value(forKey: Constant.Key.userConfigurationIsLoudNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isLoudNotificationEnabled
        UserConfiguration.isLogNotificationEnabled = fromUserDefaults.value(forKey: Constant.Key.userConfigurationIsLogNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isLogNotificationEnabled
        UserConfiguration.isReminderNotificationEnabled = fromUserDefaults.value(forKey: Constant.Key.userConfigurationIsReminderNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isReminderNotificationEnabled
        if let notificationSoundString = fromUserDefaults.value(forKey: Constant.Key.userConfigurationNotificationSound.rawValue) as? String {
            UserConfiguration.notificationSound = NotificationSound(rawValue: notificationSoundString) ?? UserConfiguration.notificationSound
        }
        
        UserConfiguration.isSilentModeEnabled = fromUserDefaults.value(forKey: Constant.Key.userConfigurationIsSilentModeEnabled.rawValue) as? Bool ?? UserConfiguration.isSilentModeEnabled
        UserConfiguration.silentModeStartUTCHour = fromUserDefaults.value(forKey: Constant.Key.userConfigurationSilentModeStartUTCHour.rawValue) as? Int ?? UserConfiguration.silentModeStartUTCHour
        UserConfiguration.silentModeEndUTCHour = fromUserDefaults.value(forKey: Constant.Key.userConfigurationSilentModeEndUTCHour.rawValue) as? Int ?? UserConfiguration.silentModeEndUTCHour
        UserConfiguration.silentModeStartUTCMinute = fromUserDefaults.value(forKey: Constant.Key.userConfigurationSilentModeStartUTCMinute.rawValue) as? Int ?? UserConfiguration.silentModeStartUTCMinute
        UserConfiguration.silentModeEndUTCMinute = fromUserDefaults.value(forKey: Constant.Key.userConfigurationSilentModeEndUTCMinute.rawValue) as? Int ?? UserConfiguration.silentModeEndUTCMinute
    }
    
    // MARK: - Main
    
    /// If OfflineModeManager.shared.shouldUpdateUser is false, sets the UserConfiguration values equal to all the values found in the body.
    static func setup(fromBody body: JSONResponseBody) {
        // This is a unique edge case. If the user updated their UserConfiguration (while offline), then terminates Hound, then re-opens Hound, the first thing the app will do is a get request to the Hound server. This would overwrite the user's local changes. Therefore, don't overwrite these changes.
        guard OfflineModeManager.shared.shouldUpdateUser == false else { return }
        
        if let interfaceStyleInt = body[Constant.Key.userConfigurationInterfaceStyle.rawValue] as? Int, let interfaceStyle = UIUserInterfaceStyle(rawValue: interfaceStyleInt) {
            self.interfaceStyle = interfaceStyle
        }
        if let measurementSystemInt = body[Constant.Key.userConfigurationMeasurementSystem.rawValue] as? Int, let measurementSystem = MeasurementSystem(rawValue: measurementSystemInt) {
            self.measurementSystem = measurementSystem
        }
        
        if let snoozeLength = body[Constant.Key.userConfigurationSnoozeLength.rawValue] as? Double {
            self.snoozeLength = snoozeLength
        }
        
        if let isNotificationEnabled = body[Constant.Key.userConfigurationIsNotificationEnabled.rawValue] as? Bool {
            self.isNotificationEnabled = isNotificationEnabled
        }
        if let isLoudNotificationEnabled = body[Constant.Key.userConfigurationIsLoudNotificationEnabled.rawValue] as? Bool {
            self.isLoudNotificationEnabled = isLoudNotificationEnabled
        }
        if let isLogNotificationEnabled = body[Constant.Key.userConfigurationIsLogNotificationEnabled.rawValue] as? Bool {
            self.isLogNotificationEnabled = isLogNotificationEnabled
        }
        if let isReminderNotificationEnabled = body[Constant.Key.userConfigurationIsReminderNotificationEnabled.rawValue] as? Bool {
            self.isReminderNotificationEnabled = isReminderNotificationEnabled
        }
        if let notificationSoundString = body[Constant.Key.userConfigurationNotificationSound.rawValue] as? String, let notificationSound = NotificationSound(rawValue: notificationSoundString) {
            self.notificationSound = notificationSound
        }
        
        if let isSilentModeEnabled = body[Constant.Key.userConfigurationIsSilentModeEnabled.rawValue] as? Bool {
            self.isSilentModeEnabled = isSilentModeEnabled
        }
        if let silentModeStartUTCHour = body[Constant.Key.userConfigurationSilentModeStartUTCHour.rawValue] as? Int {
            self.silentModeStartUTCHour = silentModeStartUTCHour
        }
        if let silentModeEndUTCHour = body[Constant.Key.userConfigurationSilentModeEndUTCHour.rawValue] as? Int {
            self.silentModeEndUTCHour = silentModeEndUTCHour
        }
        if let silentModeStartUTCMinute = body[Constant.Key.userConfigurationSilentModeStartUTCMinute.rawValue] as? Int {
            self.silentModeStartUTCMinute = silentModeStartUTCMinute
        }
        if let silentModeEndUTCMinute = body[Constant.Key.userConfigurationSilentModeEndUTCMinute.rawValue] as? Int {
            self.silentModeEndUTCMinute = silentModeEndUTCMinute
        }
    }
    
    // MARK: - In-App Appearance Related
    
    private static var storedInterfaceStyle: UIUserInterfaceStyle = .unspecified
    static var interfaceStyle: UIUserInterfaceStyle {
        get {
            storedInterfaceStyle
        }
        set {
            storedInterfaceStyle = newValue
            NotificationCenter.default.post(name: .didUpdateUserInterfaceStyle, object: nil)
        }
    }
    
    static var measurementSystem: MeasurementSystem = {
        if #available(iOS 16, *) {
            switch Locale.current.measurementSystem {
            case .metric:
                return .metric
            case .us:
                return .imperial
            case .uk:
                return .metric
            default:
                return .metric
            }
        }
        else {
            return Locale.current.usesMetricSystem ? .metric : .imperial
        }
    }()
    
    // MARK: - Alarm Timing Related
    
    static var snoozeLength: Double = Double(60 * 5)
    
    // MARK: - iOS Notification Related
    
    /// This should be stored on the server as it is important to only send notifications to devices that can use them. This will always be overriden by the user upon reinstall if its state is different in that new install.
    static var isNotificationEnabled: Bool = false
    
    /// Determines if the app should send the user loud notifications. Loud notification bypass most iPhone settings to play at max volume (Do Not Disturb, ringer off, volume off...)
    static var isLoudNotificationEnabled: Bool = false
    
    /// Determines if the server should send the user notifications when a log is created (or other similar actions)
    static var isLogNotificationEnabled: Bool = true
    
    /// Determines if the server should send the user notifications when a reminder's alarm triggers (or other similar actions)
    static var isReminderNotificationEnabled: Bool = true
    
    /// Sound a notification will play
    static var notificationSound: NotificationSound = NotificationSound.radar
    
    static var isSilentModeEnabled: Bool = false
    
    /// Hour of the day, in UTC, that silent mode will start. During silent mode, no notifications will be sent to the user
    static var silentModeStartUTCHour: Int = {
        // We want hour 22 of the day in the users local timezone (10:__ PM)
        let defaultUTCHour = 22
        let hoursFromUTC = TimeZone.current.secondsFromGMT() / 3600
        
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
        let hoursFromUTC = TimeZone.current.secondsFromGMT() / 3600
        
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
        let minutesFromUTC = (TimeZone.current.secondsFromGMT() % 3600) / 60
        
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
        let minutesFromUTC = (TimeZone.current.secondsFromGMT() % 3600) / 60
        
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
    static func createBody(addingOntoBody: JSONRequestBody?) -> JSONRequestBody {
        var body: JSONRequestBody = addingOntoBody ?? [:]
        
        body[Constant.Key.userConfigurationInterfaceStyle.rawValue] = .int(UserConfiguration.interfaceStyle.rawValue)
        body[Constant.Key.userConfigurationMeasurementSystem.rawValue] = .int(UserConfiguration.measurementSystem.rawValue)
        
        body[Constant.Key.userConfigurationSnoozeLength.rawValue] = .double(UserConfiguration.snoozeLength)
        
        body[Constant.Key.userConfigurationIsNotificationEnabled.rawValue] = .bool(UserConfiguration.isNotificationEnabled)
        body[Constant.Key.userConfigurationIsLoudNotificationEnabled.rawValue] = .bool(UserConfiguration.isLoudNotificationEnabled)
        body[Constant.Key.userConfigurationIsLogNotificationEnabled.rawValue] = .bool(UserConfiguration.isLogNotificationEnabled)
        body[Constant.Key.userConfigurationIsReminderNotificationEnabled.rawValue] = .bool(UserConfiguration.isReminderNotificationEnabled)
        body[Constant.Key.userConfigurationNotificationSound.rawValue] = .string(UserConfiguration.notificationSound.rawValue)
        
        body[Constant.Key.userConfigurationIsSilentModeEnabled.rawValue] = .bool(UserConfiguration.isSilentModeEnabled)
        body[Constant.Key.userConfigurationSilentModeStartUTCHour.rawValue] = .int(UserConfiguration.silentModeStartUTCHour)
        body[Constant.Key.userConfigurationSilentModeEndUTCHour.rawValue] = .int(UserConfiguration.silentModeEndUTCHour)
        body[Constant.Key.userConfigurationSilentModeStartUTCMinute.rawValue] = .int(UserConfiguration.silentModeStartUTCMinute)
        body[Constant.Key.userConfigurationSilentModeEndUTCMinute.rawValue] = .int(UserConfiguration.silentModeEndUTCMinute)
        
        // userNotificationToken is synced through UserRequest.update. Therefore, include it in the UserConfiguration body with the rest of the information that is updated. This is especially important for offline mode, which, if it detects a noResponse in UserRequest.update, re-syncs all of the UserConfiguration.
        body[Constant.Key.userNotificationToken.rawValue] = .string(UserInformation.userNotificationToken)
        return body
    }
}
