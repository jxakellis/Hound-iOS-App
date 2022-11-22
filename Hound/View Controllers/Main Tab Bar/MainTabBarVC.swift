//
//  MainTabBarViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//
import UIKit

final class MainTabBarViewController: UITabBarController, TimingManagerDelegate, RemindersIntroductionViewControllerDelegate, AlarmManagerDelegate, LogsViewControllerDelegate, DogsViewControllerDelegate, SettingsViewControllerDelegate {
    
    // MARK: LogsViewControllerDelegate && DogsViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)
    }
    
    // MARK: - AlarmManagerDelegate
    
    func didAddLog(sender: Sender, forDogId dogId: Int, forLog log: Log) {
        
        dogManager.findDog(forDogId: dogId)?.dogLogs.addLog(forLog: log)
        
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    func didRemoveLog(sender: Sender, forDogId dogId: Int, forLogId logId: Int) {
        
        dogManager.findDog(forDogId: dogId)?.dogLogs.removeLog(forLogId: logId)
        
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    func didRemoveReminder(sender: Sender, forDogId dogId: Int, forReminderId reminderId: Int) {
        
        let dogReminders = dogManager.findDog(forDogId: dogId)?.dogReminders
        dogReminders?.findReminder(forReminderId: reminderId)?.clearTimers()
        dogReminders?.removeReminder(forReminderId: reminderId)
        
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    // MARK: - AlarmManagerDelegate && TimingManagerDelegate
    
    func didAddReminder(sender: Sender, forDogId dogId: Int, forReminder reminder: Reminder) {
        
        dogManager.findDog(forDogId: dogId)?.dogReminders.addReminder(forReminder: reminder)
        
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    // MARK: - Dog Manager
    
    private(set) var dogManager: DogManager = DogManager()
    
    // Sets dog manager, when the value of dog manager is changed it not only changes the variable but calls other needed functions to reflect the change
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        // MainTabBarViewController will not have been fully initalized when ServerSyncViewController calls setDogManager, leading to TimingManager's delegate being nil and errors being thrown
        if (sender.localized is ServerSyncViewController) == false {
            TimingManager.initalizeReminderTimers(forDogManager: dogManager)
        }
        if (sender.localized is DogsViewController) == false {
            dogsViewController?.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        if (sender.localized is LogsViewController) == false {
            logsViewController?.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        
    }
    
    // MARK: - Properties
    
    var logsViewController: LogsViewController?
    
    var dogsViewController: DogsViewController?
    
    var settingsViewController: SettingsViewController?
    
    private var storedShouldRefreshDogManager: Bool = false
    
    /// This boolean is toggled to true when Hound recieves a 'reminder' or 'log' notification, meaning something with reminders or logs was updated and we should refresh
    var shouldRefreshDogManager: Bool {
        get {
            return storedShouldRefreshDogManager
        }
        set (newShouldRefreshDogManager) {
            
            guard newShouldRefreshDogManager == true else {
                storedShouldRefreshDogManager = false
                return
            }
            
            guard self.isViewLoaded == true && self.view.window != nil else {
                // MainTabBarViewController isn't currently in the view hierarchy, therefore indicate that once it enters the view hierarchy it needs to refresh
                storedShouldRefreshDogManager = true
                return
            }
            
            // MainTabBarViewController is in the hierarchy so have it refresh
            DogsRequest.get(invokeErrorManager: false, dogManager: dogManager) { newDogManager, _ in
                // No matter the outcome, set storedShouldRefreshDogManager to false so we don't keep invoking refreshDogManager
                self.storedShouldRefreshDogManager = false
                guard let newDogManager = newDogManager else {
                    return
                }
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
            }
        }
    }
    
    private var storedShouldRefreshFamily: Bool = false
    /// This boolean is toggled to true when Hound recieves a 'family' notification
    var shouldRefreshFamily: Bool {
        get {
            return storedShouldRefreshFamily
        }
        set (newShouldRefreshFamily) {
            
            guard newShouldRefreshFamily == true else {
                storedShouldRefreshFamily = false
                return
            }
            
            guard self.isViewLoaded == true && self.view.window != nil else {
                // MainTabBarViewController isn't currently in the view hierarchy, therefore indicate that once it enters the view hierarchy it needs to refresh
                storedShouldRefreshFamily = true
                return
            }
            
            // MainTabBarViewController is in the hierarchy so have it refresh
            FamilyRequest.get(invokeErrorManager: false, completionHandler: { _, _ in
                self.storedShouldRefreshFamily = false
            })
            
        }
    }
    
    static var mainTabBarViewController: MainTabBarViewController?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.generalLogger.notice("Version: \(UIApplication.appVersion)")
        
        logsViewController = (self.viewControllers?[0] as? UINavigationController)?.viewControllers[0] as? LogsViewController
        logsViewController?.delegate = self
        logsViewController?.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        
        dogsViewController = (self.viewControllers?[1] as? UINavigationController)?.viewControllers[0] as? DogsViewController
        dogsViewController?.delegate = self
        dogsViewController?.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        
        settingsViewController = (self.viewControllers?[2] as? UINavigationController)?.viewControllers[0] as? SettingsViewController
        settingsViewController?.delegate = self
        
        MainTabBarViewController.mainTabBarViewController = self
        
        TimingManager.delegate = self
        AlarmManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
        
        if shouldRefreshDogManager == true {
            DogsRequest.get(invokeErrorManager: false, dogManager: dogManager) { newDogManager, _ in
                // No matter the outcome, set storedShouldRefreshDogManager to false so we don't keep invoking refreshDogManager
                self.storedShouldRefreshDogManager = false
                guard let newDogManager = newDogManager else {
                    return
                }
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
            }
        }
        if shouldRefreshFamily == true {
            FamilyRequest.get(invokeErrorManager: false, completionHandler: { _, _ in
                self.storedShouldRefreshFamily = false
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Called after the view is added to the view hierarchy
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
        
        if FamilyInformation.isUserFamilyHead {
            InAppPurchaseManager.initalizeInAppPurchaseManager()
            InAppPurchaseManager.showPriceConsentIfNeeded()
        }
        CheckManager.checkForReleaseNotes()
        // Invocation of synchronizeNotificationAuthorization from willEnterForeground will only be accurate in conjuction with invocation of synchronizeNotificationAuthorization in viewDidAppear of MainTabBarViewController. This makes it so every time Hound is opened, either from the background or from terminated, notifications are properly synced.
        // 1. Hound entering foreground from being terminated. willEnterForeground isn't called upon inital launch of Hound, only once Hound is sent to background then brought back to foreground, but viewDidAppear MainTabBarViewController will catch as it's invoked once ServerSyncViewController is done loading
        // 2. Hound entering foreground after entering background. viewDidAppear MainTabBarViewController won't catch as MainTabBarViewController's view isn't appearing anymore but willEnterForeground will catch any imbalance as it's called once app is loaded to foreground
        NotificationManager.synchronizeNotificationAuthorization()
        TimingManager.initalizeReminderTimers(forDogManager: dogManager)
    }
    
    override public var shouldAutorotate: Bool {
        return false
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Functions
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let currentIndex = tabBar.items?.firstIndex(of: item)
        // self.selectedIndex is incorrect, based upon something else
        // selected the reminders page
        if currentIndex == 1 {
            // hasn't shown configuration to create reminders
            if LocalConfiguration.localHasCompletedRemindersIntroductionViewController == false {
                // Created family with no reminders
                // Joined family with no reminders
                // Joined family with reminders
                self.performSegueOnceInWindowHierarchy(segueIdentifier: "RemindersIntroductionViewController")
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let remindersIntroductionViewController: RemindersIntroductionViewController = segue.destination as? RemindersIntroductionViewController {
            remindersIntroductionViewController.delegate = self
            remindersIntroductionViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        }
    }
    
}
