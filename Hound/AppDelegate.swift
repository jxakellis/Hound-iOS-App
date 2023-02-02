//
//  AppDelegate.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import os.log
import UIKit
import UserNotifications

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    static var generalLogger = Logger(subsystem: "com.example.Pupotty", category: "General")
    static var lifeCycleLogger = Logger(subsystem: "com.example.Pupotty", category: "Life Cycle")
    static var APIRequestLogger = Logger(subsystem: "com.example.Pupotty", category: "API Request")
    static var APIResponseLogger = Logger(subsystem: "com.example.Pupotty", category: "API Response")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AppDelegate.lifeCycleLogger.notice("Application Did Finish Launching with Options")
        
        NetworkManager.shared.startMonitoring()
        
        PersistenceManager.applicationDidFinishLaunching()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        AppDelegate.lifeCycleLogger.notice("Application Will Enter Foreground")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        AppDelegate.lifeCycleLogger.notice("Application Did Enter Background")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        AppDelegate.lifeCycleLogger.notice("Application Will Terminate")
        PersistenceManager.didEnterBackground(isTerminating: true)
    }
    
    /// If the application performs didRegisterForRemoteNotificationsWithDeviceToken while a userId and/or userIdentifier are not established or loaded into memory, then the request will fail. Therefore, we check that these variables are valid. If this check fails, we set a timer to recheck every minute. We must keep track of this timer incase we need to invalidate it..
    private var userNotificationTokenTimer: Timer?
    /// The TimeInterval at which the userNotificationTokenTimer will invoke updateUserNotificationToken to attempt to update the API with the new deviceToken
    private let userNotificationTokenTimerRetryInterval: TimeInterval = 5.0
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        AppDelegate.generalLogger.notice("Successfully registered for remote notifications for token: \(token)")
        
        // If the new deviceToken is different from the saved deviceToken (i.e. there is a new token or there was no token saved), then we should attempt to update the server
        guard token != UserInformation.userNotificationToken else {
            return
        }
        
        updateUserNotificationToken()
        
        func updateUserNotificationToken() {
            // clear any existing timer for this new invocation
            userNotificationTokenTimer?.invalidate()
            userNotificationTokenTimer = nil
            
            // Check to make sure userId and userIdentifier are established. If they are not, then keep waiting userNotificationTokenTimerRetryInterval to check again. Once they are established, we send the request.
            guard UserInformation.userId != nil && UserInformation.userIdentifier != nil else {
                userNotificationTokenTimer = Timer(fire: Date().addingTimeInterval(userNotificationTokenTimerRetryInterval), interval: -1, repeats: false) { _ in
                    updateUserNotificationToken()
                }
                if let userNotificationTokenTimer = userNotificationTokenTimer {
                    RunLoop.main.add(userNotificationTokenTimer, forMode: .common)
                }
                return
            }
            
            // don't sent the user an alert if this request fails as there is no point
            UserRequest.update(invokeErrorManager: false, body: [KeyConstant.userNotificationToken.rawValue: token]) { requestWasSuccessful, _ in
                guard requestWasSuccessful else {
                    return
                }
                UserInformation.userNotificationToken = token
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AppDelegate.generalLogger.error("Failed to register for remote notifications with error: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // look for the aps body
        guard let aps = userInfo["aps"] as? [String: Any] else {
            completionHandler(.noData)
            return
        }
        
        guard let category = aps["category"] as? String else {
            completionHandler(.noData)
            return
        }
        
        if category.contains("NOTIFICATION_CATEGORY_USER_KICKED") {
            // user was kicked from their family so we should back them into the server sync meny
            AlertManager.globalPresenter?.dismissIntoServerSyncViewController()
            completionHandler(.newData)
            return
        }
        else if category.contains("NOTIFICATION_CATEGORY_FAMILY") {
            // family was updated so we should refresh the family
            MainTabBarViewController.mainTabBarViewController?.shouldRefreshFamily = true
            completionHandler(.newData)
            return
        }
        // Always refresh the dog manager when we recieve a log notification, as that means another user logged something.
        // If we invoke on 'NOTIFICATION_CATEGORY_REMINDER' as well, then everytime a reminder triggers its alarm and a notification comes thru, it will cause a refresh. This will cause a weird interaction as we will be simultaneously showing an alert in app
        else if category.contains("NOTIFICATION_CATEGORY_LOG") {
            MainTabBarViewController.mainTabBarViewController?.shouldRefreshDogManager = true
            completionHandler(.newData)
            return
        }
        // if the notification is a reminder, then check to see if loud notification can be played
        else if category.contains("NOTIFICATION_CATEGORY_REMINDER") {
            // check to see if we have a reminderLastModified available to us
            if let reminderLastModifiedString = userInfo["reminderLastModified"] as? String, let reminderLastModified = reminderLastModifiedString.formatISO8601IntoDate(), LocalConfiguration.userConfigurationPreviousDogManagerSynchronization.distance(to: reminderLastModified) > 0, let dogManager = MainTabBarViewController.mainTabBarViewController?.dogManager {
                // If the reminder was modified after the last time we synced our whole dogManager, then that means our local reminder is out of date.
                // This makes our local reminder untrustworthy. The server reminder could have been deleted (and we don't know), the server reminder could have been created (and we don't have it locally), or the server reminder could have had its timing changes (and our locally timing will be inaccurate).
                // Therefore, we should refresh the dogManager to make sure we are up to date on important features of the reminder's state: create, delete, timing.
                // Once everything is synced again, the alarm will be shown as expected.
                
                // Note: we also individually fetch a reminder before immediately constructing its alertController for its alarm. This ensure, even if the user has notifications turned off (meaning this piece of code right here won't be executed), that the reminder they are being show is up to date.
                DogsRequest.get(invokeErrorManager: false, dogManager: dogManager) { newDogManager, _ in
                    guard let newDogManager = newDogManager else {
                        return
                    }
                    MainTabBarViewController.mainTabBarViewController?.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
                }
            }
            
            AudioManager.playLoudNotification()
            
            completionHandler(.newData)
            return
        }
        
        completionHandler(.noData)
        return
    }
    
}
