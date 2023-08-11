//
//  NotificationManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/31/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum NotificationManager {

    /**
     If localIsNotificationAuthorized == true && isNotificationEnabled == true, invokes registerForRemoteNotifications then the completionHandler.
     If shouldAdviseUserBeforeRequestingNotifications == false && localIsNotificationAuthorized == false, invokes registerForRemoteNotifications then the completionHandler.
     If shouldAdviseUserBeforeRequestingNotifications == false && localIsNotificationAuthorized == false, invokes performNotificationAuthorizationRequest()
     If shouldAdviseUserBeforeRequestingNotifications == true, presents alert controller that asks the user if they want to turn on notifications. If they say yes, invokes performNotificationAuthorizationRequest(), otherwise invokes registerForRemoteNotifications then the completionHandler.
     
     performNotificationAuthorizationRequest() uses Apple's requestAuthorization to show the classic "Turn On Notifications" message. If they say yes, then we are able to send the user notifications, if they say no, then we are unable to send the user notifications. Regardless of the result, we update LocalConfiguration and contact the Hound server.
     */
    static func requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: Bool, completionHandler: (() -> Void)?) {
        guard LocalConfiguration.localIsNotificationAuthorized == false || UserConfiguration.isNotificationEnabled == false else {
            // If localIsNotificationAuthorized == true && isNotificationEnabled == true, there is no purpose in asking the user to request notification authorization. They are already authorized and have notifications enabled. Simply, re-register for remote notifications (repeated re-registering recommended by apple; user could be unregistered for remoteNotifications).
            registerForRemoteNotificationsIfAuthorized()
            completionHandler?()
            return
        }

        // If shouldAdviseUserBeforeRequestingNotifications == true, we present our alert controller that asks the user if they want notifications. We only have one use of Apple's notification prompt, so this prevents wasting that one by seeing if the user wants notifications.
        guard shouldAdviseUserBeforeRequestingNotifications == true else {
            // If adviseUserBeforeRequestingNotifications == false, check the localIsNotificationAuthorized status.
            if LocalConfiguration.localIsNotificationAuthorized == true {
                // If localIsNotificationAuthorized == true, then re-register for remote notifications (repeated re-registering recommended by apple; user could be unregistered for remoteNotifications). Don't change user's notification settings as they could have already configured them since localIsNotificationAuthorized == true.
                registerForRemoteNotificationsIfAuthorized()
                completionHandler?()
            }
            else {
                // If localIsNotificationAuthorized == false, then notification haven't been approved. Therefore, we can request notifications and override any non-user-configured notification settings
                performNotificationAuthorizationRequest()
            }
            return
        }

        let askUserAlertController = UIAlertController(title: "Do you want to turn on notifications?", message: "Don't miss out on important events like your dog needing a helping hand or a family member adding a log", preferredStyle: .alert)

        let turnOnNotificationsAlertAction = UIAlertAction(title: "Turn On Notifications", style: .default) { _ in
            performNotificationAuthorizationRequest()
        }

        let notNowAlertAction = UIAlertAction(title: "Not Now", style: .cancel) { _ in
            registerForRemoteNotificationsIfAuthorized()
            completionHandler?()
        }

        askUserAlertController.addAction(turnOnNotificationsAlertAction)
        askUserAlertController.addAction(notNowAlertAction)

        PresentationManager.enqueueAlert(askUserAlertController)

        func performNotificationAuthorizationRequest() {
            let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
            let beforeUpdateIsLoudNotificationEnabled = UserConfiguration.isLoudNotificationEnabled
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay]) { isGranted, _ in
                LocalConfiguration.localIsNotificationAuthorized = isGranted
                registerForRemoteNotificationsIfAuthorized()

                UserConfiguration.isNotificationEnabled = isGranted
                UserConfiguration.isLoudNotificationEnabled = isGranted

                // Contact the server about the updated values and, if there is no response or a bad response, revert the values to their previous values. localIsNotificationAuthorized purposefully excluded as server doesn't need to know that and its value is untrust worthy (user can modify the value without us knowing, unlike our custom variables).
                let body: [String: Any] = [
                    KeyConstant.userConfigurationIsNotificationEnabled.rawValue: UserConfiguration.isNotificationEnabled, KeyConstant.userConfigurationIsLoudNotificationEnabled.rawValue: UserConfiguration.isLoudNotificationEnabled
                ]

                UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
                    if requestWasSuccessful == false {
                        UserConfiguration.isNotificationEnabled = beforeUpdateIsNotificationEnabled
                        UserConfiguration.isLoudNotificationEnabled = beforeUpdateIsLoudNotificationEnabled
                    }
                    DispatchQueue.main.async {
                        completionHandler?()
                    }
                }
            }
        }

    }

    private static func registerForRemoteNotificationsIfAuthorized() {
        guard LocalConfiguration.localIsNotificationAuthorized == true else {
            return
        }

        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    /// Checks to see that the status of localIsNotificationAuthorized matches the status of other notification settings. If there is an imbalance in notification settings or a change has occured, then updates the local settings and server settings to fix the issue
    static func synchronizeNotificationAuthorization() {
        let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
        let beforeUpdateIsLoudNotificationEnabled = UserConfiguration.isLoudNotificationEnabled

        UNUserNotificationCenter.current().getNotificationSettings { permission in
            switch permission.authorizationStatus {
            case .authorized:
                authorizeNotifications()
            case .denied:
                denyNotifications()
            case .notDetermined:
                denyNotifications()
            case .provisional:
                authorizeNotifications()
            case .ephemeral:
                authorizeNotifications()
            @unknown default:
                denyNotifications()
            }
        }

        /// Enables localIsNotificationAuthorized and checks to make sure that the user is registered for remote notifications
        func authorizeNotifications() {
            // Notifications are authorized
            LocalConfiguration.localIsNotificationAuthorized = true
            // Never cache device tokens in your app; instead, get them from the system when you need them. APNs issues a new device token to your app when certain events happen.
            registerForRemoteNotificationsIfAuthorized()
        }

        /// Disables localIsNotificationAuthorized and checks to make sure that the other notification settings align (making sure there is no imbalance, e.g. isNotificationEnabled == true but localIsNotificationAuthorized == false)
        func denyNotifications() {
            LocalConfiguration.localIsNotificationAuthorized = false

            // The user isn't authorized for notifications, therefore all of those settings should be false. If any of those settings aren't false, representing an imbalance, then we should fix this imbalance and update the Hound server
            guard UserConfiguration.isNotificationEnabled == true || UserConfiguration.isLoudNotificationEnabled == true else {
                return
            }

            UserConfiguration.isNotificationEnabled = false
            UserConfiguration.isLoudNotificationEnabled = false
            DispatchQueue.main.async {
                // The isNotificationAuthorized, isNotificationEnabled, and isLoudNotificationEnabled have been potentially updated. Additionally, settingsNotificationsTableViewController could be be the last view opened. Therefore, we need to inform settingsNotificationsTableViewController of these changes so that it can update its switches.
                SettingsNotificationsTableViewController.didSynchronizeNotificationAuthorization()
            }
            var body: [String: Any] = [:]
            // check for if values were changed, if there were then tell the server
            if UserConfiguration.isNotificationEnabled != beforeUpdateIsNotificationEnabled {
                body[KeyConstant.userConfigurationIsNotificationEnabled.rawValue] = UserConfiguration.isNotificationEnabled
            }
            if UserConfiguration.isLoudNotificationEnabled != beforeUpdateIsLoudNotificationEnabled {
                body[KeyConstant.userConfigurationIsLoudNotificationEnabled.rawValue] = UserConfiguration.isLoudNotificationEnabled
            }

            guard body.keys.isEmpty == false else {
                return
            }
            UserRequest.update(invokeErrorManager: false, body: body) { requestWasSuccessful, _ in
                guard requestWasSuccessful == false else {
                    return
                }
                // error with communication the change to the server, therefore revert local values to previous state
                UserConfiguration.isNotificationEnabled = beforeUpdateIsNotificationEnabled
                UserConfiguration.isLoudNotificationEnabled = beforeUpdateIsLoudNotificationEnabled

                // The isNotificationAuthorized, isNotificationEnabled, and isLoudNotificationEnabled have been potentially updated. Additionally, settingsNotificationsTableViewController could be be the last view opened. Therefore, we need to inform settingsNotificationsTableViewController of these changes so that it can update its switches.
                SettingsNotificationsTableViewController.didSynchronizeNotificationAuthorization()
            }
        }
    }

}
