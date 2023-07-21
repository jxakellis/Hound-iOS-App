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
     If shouldAdviseUserBeforeRequestingNotifications is true, presents an alert controller that asks the user if they want to turn on notifications. This alert controller tells them the benefits of turning on notifications. Additionally, this alert prevents the user from interacting with Apple's "turn on notifications" message until they say they want to turn on notifications, reducing the chance that they hit "Don't Allow (notifications)"
     
     DOES update local UserConfiguration. Requests permission to send notifications to the user then invokes updateServerUserNotificationConfiguration. If the server returned a 200 status and is successful, then return. Otherwise, if the user didn't grant permission or there was a problem with the  query, then return and (if needed) ErrorManager is automatically invoked
    */
    static func requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: Bool, completionHandler: @escaping () -> Void) {
        // If adviseUserBeforeRequestingNotifications == true, we can ignore the localIsNotificationAuthorized status.
        // This is because we want to always invoke our view controller to ask the user if they want notification. If they say yes, then it either immediately turns everything on (if localIsNotificationAuthorized == true) or we invoke the apple 'Allow Notifications' prompt to then turn everything on (if localIsNotificationAuthorized == false).
        
        if shouldAdviseUserBeforeRequestingNotifications == false && LocalConfiguration.localIsNotificationAuthorized == true {
            // If adviseUserBeforeRequestingNotifications == false, check the localIsNotificationAuthorized status.
            // If localIsNotificationAuthorized == true, then re-register for remote notifications (repeated re-registering recommended by apple). Don't change user's notification settings as they could have already configured them since localIsNotificationAuthorized == true.
            // If localIsNotificationAuthorized == false, then notification haven't been approved. Therefore, we can request notifications and override any non-user-configured notification settings
            
            // A user could potentially be localIsNotificationAuthorized == true but unregistered for remoteNotications
            UIApplication.shared.registerForRemoteNotifications()
            completionHandler()
            return
        }
        
        // Check to see if we need to ask the user first about wanting notifications, before showing Apple's notification prompt. This helps reduce the chances that a user will disable notifications when they really should have turned them on.
        guard shouldAdviseUserBeforeRequestingNotifications == true else {
            performNotificationAuthorizationRequest()
            return
        }
        
        let askUserAlertController = UIAlertController(title: "Do you want to turn on notifications?", message: "Hound's notifications alert you about important events, such as your dog needing a helping hand or logs of care being added.", preferredStyle: .alert)
        
        let turnOnNotificationsAlertAction = UIAlertAction(title: "Turn On Notifications", style: .default) { _ in
            performNotificationAuthorizationRequest()
        }
        
        let notNowAlertAction = UIAlertAction(title: "Not Now", style: .cancel) { _ in
            completionHandler()
        }
        
        askUserAlertController.addAction(turnOnNotificationsAlertAction)
        askUserAlertController.addAction(notNowAlertAction)
        
        PresentationManager.enqueueAlert(askUserAlertController)
        
        func performNotificationAuthorizationRequest() {
            let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
            let beforeUpdateIsLoudNotificationEnabled = UserConfiguration.isLoudNotificationEnabled
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, _) in
                LocalConfiguration.localIsNotificationAuthorized = isGranted
                UserConfiguration.isNotificationEnabled = isGranted
                UserConfiguration.isLoudNotificationEnabled = isGranted
                
                if LocalConfiguration.localIsNotificationAuthorized == true {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                
                // Contact the server about the updated values and, if there is no response or a bad response, revert the values to their previous values. localIsNotificationAuthorized purposefully excluded as server doesn't need to know that and its value cant exactly just be flipped (as tied to apple notif auth status)
                let body: [String: Any] = [
                    KeyConstant.userConfigurationIsNotificationEnabled.rawValue: UserConfiguration.isNotificationEnabled, KeyConstant.userConfigurationIsLoudNotificationEnabled.rawValue: UserConfiguration.isLoudNotificationEnabled
                ]
                UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
                    if requestWasSuccessful == false {
                        UserConfiguration.isNotificationEnabled = beforeUpdateIsNotificationEnabled
                        UserConfiguration.isLoudNotificationEnabled = beforeUpdateIsLoudNotificationEnabled
                    }
                    completionHandler()
                }
            }
        }
        
    }
    
    /// Checks to see that the status of localIsNotificationAuthorized matches the status of other notification settings. If there is an imbalance in notification settings or a change has occured, then updates the local settings and server settings to fix the issue
    static func synchronizeNotificationAuthorization() {
        let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
        let beforeUpdateIsLoudNotificationEnabled = UserConfiguration.isLoudNotificationEnabled
        
        UNUserNotificationCenter.current().getNotificationSettings { (permission) in
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
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
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
            // Updates switch to reflect change, if the last view open was the settings page then the app is exitted and property changed in the settings app then this app is reopened, VWL will not be called as the settings page was already opened, weird edge case.
            DispatchQueue.main.async {
                MainTabBarViewController.mainTabBarViewController?.settingsViewController?.settingsNotificationsTableViewController?.synchronizeAllValues(animated: true)
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
                
                MainTabBarViewController.mainTabBarViewController?.settingsViewController?.settingsNotificationsTableViewController?.synchronizeAllValues(animated: true)
            }
        }
    }
    
}
