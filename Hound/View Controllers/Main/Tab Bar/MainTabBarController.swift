//
//  MainTabBarController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//
import UIKit

final class MainTabBarController: UITabBarController, TimingManagerDelegate, RemindersIntroductionViewControllerDelegate, AlarmManagerDelegate, LogsViewControllerDelegate, DogsViewControllerDelegate, SettingsViewControllerDelegate {
    
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
        
        // MainTabBarController will not have been fully initalized when ServerSyncViewController calls setDogManager, leading to TimingManager's delegate being nil and errors being thrown
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
    
    static var mainTabBarController: MainTabBarController?
    
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
            
            guard self.viewIfLoaded?.window != nil else {
                // MainTabBarController isn't currently in the view hierarchy, therefore indicate that once it enters the view hierarchy it needs to refresh
                storedShouldRefreshDogManager = true
                return
            }
            
            // MainTabBarController is in the hierarchy so have it refresh
            DogsRequest.get(invokeErrorManager: false, dogManager: self.dogManager) { newDogManager, _ in
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
            
            guard self.viewIfLoaded?.window != nil else {
                // MainTabBarController isn't currently in the view hierarchy, therefore indicate that once it enters the view hierarchy it needs to refresh
                storedShouldRefreshFamily = true
                return
            }
            
            // MainTabBarController is in the hierarchy so have it refresh
            FamilyRequest.get(invokeErrorManager: false, completionHandler: { _, _ in
                self.storedShouldRefreshFamily = false
            })
            
        }
    }
    
    var tabBarUpperLineView: UIView?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.generalLogger.notice("Version: \(UIApplication.appVersion)")
        
        logsViewController = (self.viewControllers?.first as? UINavigationController)?.viewControllers.first as? LogsViewController
        logsViewController?.delegate = self
        logsViewController?.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        
        dogsViewController = (self.viewControllers?.safeIndex(1) as? UINavigationController)?.viewControllers.first as? DogsViewController
        dogsViewController?.delegate = self
        dogsViewController?.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        
        settingsViewController = (self.viewControllers?.safeIndex(2) as? UINavigationController)?.viewControllers.first as? SettingsViewController
        settingsViewController?.delegate = self
        
        MainTabBarController.mainTabBarController = self
        
        TimingManager.delegate = self
        AlarmManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // This page, and its children, can be light or dark
        self.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
        
        if shouldRefreshDogManager == true {
            DogsRequest.get(invokeErrorManager: false, dogManager: self.dogManager) { newDogManager, _ in
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
    
    /// Certain views must be adapted in viewDidLayoutSubviews as properties (such as frames) are not updated until the subviews are laid out (before that point in time they hold the placeholder storyboard value). However, viewDidLayoutSubviews is called multiple times, therefore we must lock it to executing certain code once with this variable. viewDidLayoutSubviews is the superior choice to viewDidAppear as viewDidAppear has the downside of performing these changes once the user can see the view
    private var didSetupCustomSubviews: Bool = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // MainTabBarController IS NOT EMBEDDED inside other view controllers. This means IT HAS safe area insets. Only the view controllers that are presented onto MainTabBarController or are in the navigation stack have safe area insets. This is because those views take up the whole screen, so they MUST consider the phone's safe area (i.e. top bar with time, wifi, and battery and bottom bar).
        
        guard didSetupSafeArea() == true && didSetupCustomSubviews == false else {
            return
        }
        
        self.didSetupCustomSubviews = true
        
        // Adding this task to DispatchQueue delays it ever so slightly. This prevents an odd bug where the upperLine is incorrectly created and displayed, even through the subviews and safe area has been established properly.
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.addTabBarUpperLine(forIndex: self.selectedIndex)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Called after the view is added to the view hierarchy
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
        
        if FamilyInformation.isUserFamilyHead {
            InAppPurchaseManager.initalizeInAppPurchaseManager()
            InAppPurchaseManager.showPriceConsentIfNeeded()
        }
        
        CheckManager.checkForReleaseNotes()
        // Invocation of synchronizeNotificationAuthorization from willEnterForeground will only be accurate in conjuction with invocation of synchronizeNotificationAuthorization in viewDidAppear of MainTabBarController. This makes it so every time Hound is opened, either from the background or from terminated, notifications are properly synced.
        // 1. Hound entering foreground from being terminated. willEnterForeground isn't called upon inital launch of Hound, only once Hound is sent to background then brought back to foreground, but viewDidAppear MainTabBarController will catch as it's invoked once ServerSyncViewController is done loading
        // 2. Hound entering foreground after entering background. viewDidAppear MainTabBarController won't catch as MainTabBarController's view isn't appearing anymore but willEnterForeground will catch any imbalance as it's called once app is loaded to foreground
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
        // self.selectedIndex is incorrect. It is the the index before this new item was selected
        let newIndex = tabBar.items?.firstIndex(of: item)
        
        guard let newIndex = newIndex else {
            return
        }
        
        addTabBarUpperLine(forIndex: newIndex)
        
        // The user has selected the reminders tab and has not completed the reminders introduction page
        if newIndex == 1 && LocalConfiguration.localHasCompletedRemindersIntroductionViewController == false {
            
            if dogManager.hasCreatedReminder == false {
                // The family needs reminders, so we proceed as normal
                self.performSegueOnceInWindowHierarchy(segueIdentifier: "RemindersIntroductionViewController")
            }
            else {
                // The family doesn't need reminders, so just ask the user for notifications
                NotificationManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: true, completionHandler: nil)
            }
            
        }
    }
    
    private func addTabBarUpperLine(forIndex index: Int) {
        // We cannot access the UIView of the UITabBarItems. However, this is an undocumented workaround to access the underlying view.
        guard let tabView = tabBar.items?[index].value(forKey: "view") as? UIView else {
            return
        }
        
        tabBarUpperLineView?.removeFromSuperview()
        
        let upperLineInsetFromEdges = tabView.frame.width * 0.15
        
        tabBarUpperLineView = UIView(
            frame: CGRect(
                x: tabView.frame.minX + upperLineInsetFromEdges,
                y: tabView.frame.minY + 0.1,
                width: tabView.frame.width - (upperLineInsetFromEdges * 2),
                height: 2.0)
        )
        tabBarUpperLineView?.backgroundColor = UIColor.systemBlue
        
        if let tabBarUpperLineView = tabBarUpperLineView {
            tabBar.addSubview(tabBarUpperLineView)
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
