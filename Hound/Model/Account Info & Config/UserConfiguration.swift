//
//  UserConfiguration.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/7/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO TEST TIME test that new silent mode calculations on the server actually work

/// Configuration that is local to the app only. If the app is reinstalled then this data should be pulled down from the cloud
final class UserConfiguration: UserDefaultPersistable {
    
    // MARK: - UserDefaultPersistable
    
    static func persist(toUserDefaults: UserDefaults) {
        toUserDefaults.set(UserConfiguration.interfaceStyle.rawValue, forKey: Constant.Key.userConfigurationInterfaceStyle.rawValue)
        toUserDefaults.set(UserConfiguration.measurementSystem.rawValue, forKey: Constant.Key.userConfigurationMeasurementSystem.rawValue)
        toUserDefaults.set(UserConfiguration.isHapticsEnabled, forKey: Constant.Key.userConfigurationIsHapticsEnabled.rawValue)
        toUserDefaults.set(UserConfiguration.usesDeviceTimeZone, forKey: Constant.Key.userConfigurationUsesDeviceTimeZone.rawValue)
        toUserDefaults.set(UserConfiguration.userTimeZone?.identifier, forKey: Constant.Key.userConfigurationUserTimeZone.rawValue)
        
        toUserDefaults.set(UserConfiguration.notificationSound.rawValue, forKey: Constant.Key.userConfigurationNotificationSound.rawValue)
        
        toUserDefaults.set(UserConfiguration.isNotificationEnabled, forKey: Constant.Key.userConfigurationIsNotificationEnabled.rawValue)
        toUserDefaults.set(UserConfiguration.isLoudNotificationEnabled, forKey: Constant.Key.userConfigurationIsLoudNotificationEnabled.rawValue)
        toUserDefaults.set(UserConfiguration.isLogNotificationEnabled, forKey: Constant.Key.userConfigurationIsLogNotificationEnabled.rawValue)
        toUserDefaults.set(UserConfiguration.isReminderNotificationEnabled, forKey: Constant.Key.userConfigurationIsReminderNotificationEnabled.rawValue)
        
        toUserDefaults.set(UserConfiguration.isSilentModeEnabled, forKey: Constant.Key.userConfigurationIsSilentModeEnabled.rawValue)
        toUserDefaults.set(UserConfiguration.silentModeStartHour, forKey: Constant.Key.userConfigurationSilentModeStartHour.rawValue)
        toUserDefaults.set(UserConfiguration.silentModeEndHour, forKey: Constant.Key.userConfigurationSilentModeEndHour.rawValue)
        toUserDefaults.set(UserConfiguration.silentModeStartMinute, forKey: Constant.Key.userConfigurationSilentModeStartMinute.rawValue)
        toUserDefaults.set(UserConfiguration.silentModeEndMinute, forKey: Constant.Key.userConfigurationSilentModeEndMinute.rawValue)
    }
    
    static func load(fromUserDefaults: UserDefaults) {
        // NOTE: User Configuration is stored on the Hound server and retrieved synced. However, if the user is in offline mode, they will need these values. Therefore, use local storage as a second backup for these values
        
        if let interfaceStyleInt = fromUserDefaults.value(forKey: Constant.Key.userConfigurationInterfaceStyle.rawValue) as? Int {
            UserConfiguration.interfaceStyle = UIUserInterfaceStyle(rawValue: interfaceStyleInt) ?? UserConfiguration.interfaceStyle
        }
        if let measurementSystemInt = fromUserDefaults.value(forKey: Constant.Key.userConfigurationMeasurementSystem.rawValue) as? Int {
            UserConfiguration.measurementSystem = MeasurementSystem(rawValue: measurementSystemInt) ?? UserConfiguration.measurementSystem
        }
        UserConfiguration.isHapticsEnabled = fromUserDefaults.value(forKey: Constant.Key.userConfigurationIsHapticsEnabled.rawValue) as? Bool ?? UserConfiguration.isHapticsEnabled
        UserConfiguration.usesDeviceTimeZone = fromUserDefaults.value(forKey: Constant.Key.userConfigurationUsesDeviceTimeZone.rawValue) as? Bool ?? UserConfiguration.usesDeviceTimeZone
        UserConfiguration.userTimeZone = {
            if let str = fromUserDefaults.value(forKey: Constant.Key.userConfigurationUserTimeZone.rawValue) as? String {
                return TimeZone(identifier: str)
            }
            return nil
        }() ?? UserConfiguration.userTimeZone
        
        UserConfiguration.snoozeLength = fromUserDefaults.value(forKey: Constant.Key.userConfigurationSnoozeLength.rawValue) as? Double ?? UserConfiguration.snoozeLength
        
        UserConfiguration.isNotificationEnabled = fromUserDefaults.value(forKey: Constant.Key.userConfigurationIsNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isNotificationEnabled
        UserConfiguration.isLoudNotificationEnabled = fromUserDefaults.value(forKey: Constant.Key.userConfigurationIsLoudNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isLoudNotificationEnabled
        UserConfiguration.isLogNotificationEnabled = fromUserDefaults.value(forKey: Constant.Key.userConfigurationIsLogNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isLogNotificationEnabled
        UserConfiguration.isReminderNotificationEnabled = fromUserDefaults.value(forKey: Constant.Key.userConfigurationIsReminderNotificationEnabled.rawValue) as? Bool ?? UserConfiguration.isReminderNotificationEnabled
        if let notificationSoundString = fromUserDefaults.value(forKey: Constant.Key.userConfigurationNotificationSound.rawValue) as? String {
            UserConfiguration.notificationSound = NotificationSound(rawValue: notificationSoundString) ?? UserConfiguration.notificationSound
        }
        
        UserConfiguration.isSilentModeEnabled = fromUserDefaults.value(forKey: Constant.Key.userConfigurationIsSilentModeEnabled.rawValue) as? Bool ?? UserConfiguration.isSilentModeEnabled
        UserConfiguration.silentModeStartHour = fromUserDefaults.value(forKey: Constant.Key.userConfigurationSilentModeStartHour.rawValue) as? Int ?? UserConfiguration.silentModeStartHour
        UserConfiguration.silentModeEndHour = fromUserDefaults.value(forKey: Constant.Key.userConfigurationSilentModeEndHour.rawValue) as? Int ?? UserConfiguration.silentModeEndHour
        UserConfiguration.silentModeStartMinute = fromUserDefaults.value(forKey: Constant.Key.userConfigurationSilentModeStartMinute.rawValue) as? Int ?? UserConfiguration.silentModeStartMinute
        UserConfiguration.silentModeEndMinute = fromUserDefaults.value(forKey: Constant.Key.userConfigurationSilentModeEndMinute.rawValue) as? Int ?? UserConfiguration.silentModeEndMinute
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
        if let isHapticsEnabled = body[Constant.Key.userConfigurationIsHapticsEnabled.rawValue] as? Bool {
            self.isHapticsEnabled = isHapticsEnabled
        }
        if let usesDeviceTimeZone = body[Constant.Key.userConfigurationUsesDeviceTimeZone.rawValue] as? Bool {
            self.usesDeviceTimeZone = usesDeviceTimeZone
        }
        if let userTimeZone = body[Constant.Key.userConfigurationUserTimeZone.rawValue] as? String {
            self.userTimeZone = TimeZone(identifier: userTimeZone)
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
        if let silentModeStartHour = body[Constant.Key.userConfigurationSilentModeStartHour.rawValue] as? Int {
            self.silentModeStartHour = silentModeStartHour
        }
        if let silentModeEndHour = body[Constant.Key.userConfigurationSilentModeEndHour.rawValue] as? Int {
            self.silentModeEndHour = silentModeEndHour
        }
        if let silentModeStartMinute = body[Constant.Key.userConfigurationSilentModeStartMinute.rawValue] as? Int {
            self.silentModeStartMinute = silentModeStartMinute
        }
        if let silentModeEndMinute = body[Constant.Key.userConfigurationSilentModeEndMinute.rawValue] as? Int {
            self.silentModeEndMinute = silentModeEndMinute
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
    
    static var isHapticsEnabled: Bool = true
    
    static var usesDeviceTimeZone: Bool = true {
        didSet {
            if oldValue != usesDeviceTimeZone {
                NotificationCenter.default.post(name: .didUpdateUserTimeZone, object: nil)
            }
        }
    }
    
    static var userTimeZone: TimeZone? {
        didSet {
            if oldValue != userTimeZone {
                NotificationCenter.default.post(name: .didUpdateUserTimeZone, object: nil)
            }
        }
    }
    
    static var deviceTimeZone: TimeZone {
        return TimeZone.current
    }
    /// If usesTimeZone is true, this simply returns the device timeZone. Otherwise, it attempts to use the userTimeZone (possibly configured) to load the TZ
    static var timeZone: TimeZone {
        return usesDeviceTimeZone ? deviceTimeZone : userTimeZone ?? deviceTimeZone
    }
    
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
    
    /// Hour of the day, in UTC, that silent mode will start. During silent mode, no notifications will be sent to the user. Default 10 PM
    static var silentModeStartHour: Int = 22
    
    /// Hour of the day, in UTC, that silent mode will end. During silent mode, no notifications will be sent to the user. Default 5 AM
    static var silentModeEndHour: Int = 5
    
    static var silentModeStartMinute: Int = 0
    
    static var silentModeEndMinute: Int = 0
}

extension UserConfiguration {
    // MARK: - Request
    
    /// Returns an array literal of the user configurations's properties. This is suitable to be used as the JSON body for a HTTP request
    static func createBody(addingOntoBody: JSONRequestBody?) -> JSONRequestBody {
        var body: JSONRequestBody = addingOntoBody ?? [:]
        
        body[Constant.Key.userConfigurationInterfaceStyle.rawValue] = .int(UserConfiguration.interfaceStyle.rawValue)
        body[Constant.Key.userConfigurationMeasurementSystem.rawValue] = .int(UserConfiguration.measurementSystem.rawValue)
        body[Constant.Key.userConfigurationIsHapticsEnabled.rawValue] = .bool(UserConfiguration.isHapticsEnabled)
        body[Constant.Key.userConfigurationUsesDeviceTimeZone.rawValue] = .bool(UserConfiguration.usesDeviceTimeZone)
        body[Constant.Key.userConfigurationUserTimeZone.rawValue] = .string(UserConfiguration.userTimeZone?.identifier)
        
        body[Constant.Key.userConfigurationSnoozeLength.rawValue] = .double(UserConfiguration.snoozeLength)
        
        body[Constant.Key.userConfigurationIsNotificationEnabled.rawValue] = .bool(UserConfiguration.isNotificationEnabled)
        body[Constant.Key.userConfigurationIsLoudNotificationEnabled.rawValue] = .bool(UserConfiguration.isLoudNotificationEnabled)
        body[Constant.Key.userConfigurationIsLogNotificationEnabled.rawValue] = .bool(UserConfiguration.isLogNotificationEnabled)
        body[Constant.Key.userConfigurationIsReminderNotificationEnabled.rawValue] = .bool(UserConfiguration.isReminderNotificationEnabled)
        body[Constant.Key.userConfigurationNotificationSound.rawValue] = .string(UserConfiguration.notificationSound.rawValue)
        
        body[Constant.Key.userConfigurationIsSilentModeEnabled.rawValue] = .bool(UserConfiguration.isSilentModeEnabled)
        body[Constant.Key.userConfigurationSilentModeStartHour.rawValue] = .int(UserConfiguration.silentModeStartHour)
        body[Constant.Key.userConfigurationSilentModeEndHour.rawValue] = .int(UserConfiguration.silentModeEndHour)
        body[Constant.Key.userConfigurationSilentModeStartMinute.rawValue] = .int(UserConfiguration.silentModeStartMinute)
        body[Constant.Key.userConfigurationSilentModeEndMinute.rawValue] = .int(UserConfiguration.silentModeEndMinute)
        
        // userNotificationToken is synced through UserRequest.update. Therefore, include it in the UserConfiguration body with the rest of the information that is updated. This is especially important for offline mode, which, if it detects a noResponse in UserRequest.update, re-syncs all of the UserConfiguration.
        body[Constant.Key.userNotificationToken.rawValue] = .string(UserInformation.userNotificationToken)
        return body
    }
}
