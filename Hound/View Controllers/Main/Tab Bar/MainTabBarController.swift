//
//  MainTabBarController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//
import UIKit

final class MainTabBarController: GeneralUITabBarController, TimingManagerDelegate, RemindersIntroductionViewControllerDelegate, AlarmManagerDelegate, LogsViewControllerDelegate, DogsViewControllerDelegate, SettingsPagesTableViewControllerDelegate, OfflineModeManagerDelegate {
    
    // MARK: LogsViewControllerDelegate && DogsViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)
    }
    
    // MARK: - AlarmManagerDelegate
    
    func didAddLog(sender: Sender, forDogUUID: UUID, forLog log: Log) {
        
        dogManager.findDog(forDogUUID: forDogUUID)?.dogLogs.addLog(forLog: log)
        
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    func didRemoveLog(sender: Sender, forDogUUID: UUID, forLogUUID: UUID) {
        
        dogManager.findDog(forDogUUID: forDogUUID)?.dogLogs.removeLog(forLogUUID: forLogUUID)
        
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    func didRemoveReminder(sender: Sender, forDogUUID: UUID, forReminderUUID: UUID) {
        
        let dogReminders = dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders
        dogReminders?.findReminder(forReminderUUID: forReminderUUID)?.clearTimers()
        dogReminders?.removeReminder(forReminderUUID: forReminderUUID)
        
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    // MARK: - AlarmManagerDelegate && TimingManagerDelegate
    
    func didAddReminder(sender: Sender, forDogUUID: UUID, forReminder reminder: Reminder) {
        
        dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders.addReminder(forReminder: reminder)
        
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    // MARK: - Dog Manager
    
    private var dogManager: DogManager = DogManager.globalDogManager ?? DogManager()
    
    // Sets dog manager, when the value of dog manager is changed it not only changes the variable but calls other needed functions to reflect the change
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        DogManager.globalDogManager = dogManager
        
        // MainTabBarController will not have been fully initialized when ServerSyncViewController calls setDogManager, leading to TimingManager's delegate being nil and errors being thrown
        if (sender.localized is ServerSyncViewController) == false {
            TimingManager.initializeReminderTimers(forDogManager: dogManager)
        }
        if (sender.localized is DogsViewController) == false {
            dogsViewController?.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        if (sender.localized is LogsViewController) == false {
            logsViewController?.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        
    }
    
    // MARK: - Properties
    
    private static var mainTabBarController: MainTabBarController?
    
    private var logsViewController: LogsViewController?
    
    private var dogsViewController: DogsViewController?
    
    private var settingsPagesTableViewController: SettingsPagesTableViewController?
    
    var tabBarUpperLineView: UIView?
    
    /// Returns true if MainTabBarController.mainTabBarController?.viewIfLoaded?.window is not nil
    static var isInViewHierarchy: Bool {
        return MainTabBarController.mainTabBarController?.viewIfLoaded?.window != nil
    }
    
    /// This boolean is toggled to true when Hound recieves a 'reminder' or 'log' notification, meaning something with reminders or logs was updated and we should refresh
    static var shouldRefreshDogManager: Bool = false {
        didSet {
            guard shouldRefreshDogManager == true else {
                return
            }
            
            guard let mainTabBarController = MainTabBarController.mainTabBarController, mainTabBarController.viewIfLoaded?.window != nil else {
                // MainTabBarController isn't currently in the view hierarchy, therefore indicate that once it enters the view hierarchy it needs to refresh
                return
            }
            
            // MainTabBarController is in the hierarchy so have it refresh
            DogsRequest.get(forErrorAlert: .automaticallyAlertForNone, forDogManager: mainTabBarController.dogManager) { newDogManager, _, _ in
                // No matter the outcome, set storedShouldRefreshDogManager to false so we don't keep invoking refreshDogManager
                MainTabBarController.shouldRefreshDogManager = false
                
                guard let newDogManager = newDogManager else {
                    return
                }
                
                mainTabBarController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
            }
        }
    }
    
    /// This boolean is toggled to true when Hound recieves a 'family' notification
    static var shouldRefreshFamily: Bool = false {
        didSet {
            guard shouldRefreshFamily == true else {
                return
            }
            
            guard MainTabBarController.mainTabBarController?.viewIfLoaded?.window != nil else {
                // MainTabBarController isn't currently in the view hierarchy, therefore indicate that once it enters the view hierarchy it needs to refresh
                return
            }
            
            // MainTabBarController is in the hierarchy so have it refresh
            FamilyRequest.get(forErrorAlert: .automaticallyAlertForNone, completionHandler: { _, _  in
                MainTabBarController.shouldRefreshFamily = false
            })
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        AppDelegate.generalLogger.notice("Version: \(UIApplication.appVersion)")
        
        logsViewController = (self.viewControllers?.first as? UINavigationController)?.viewControllers.first as? LogsViewController
        logsViewController?.delegate = self
        logsViewController?.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        
        dogsViewController = (self.viewControllers?.safeIndex(1) as? UINavigationController)?.viewControllers.first as? DogsViewController
        dogsViewController?.delegate = self
        dogsViewController?.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        
        settingsPagesTableViewController = (self.viewControllers?.safeIndex(2) as? UINavigationController)?.viewControllers.first as? SettingsPagesTableViewController
        settingsPagesTableViewController?.delegate = self
        
        MainTabBarController.mainTabBarController = self
        
        TimingManager.delegate = self
        AlarmManager.delegate = self
        OfflineModeManager.shared.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if MainTabBarController.shouldRefreshDogManager == true {
            DogsRequest.get(forErrorAlert: .automaticallyAlertForNone, forDogManager: self.dogManager) { newDogManager, _, _ in
                // No matter the outcome, set storedShouldRefreshDogManager to false so we don't keep invoking refreshDogManager
                MainTabBarController.shouldRefreshDogManager = false
                guard let newDogManager = newDogManager else {
                    return
                }
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
            }
        }
        if MainTabBarController.shouldRefreshFamily == true {
            FamilyRequest.get(forErrorAlert: .automaticallyAlertForNone, completionHandler: { _, _ in
                MainTabBarController.shouldRefreshFamily = false
            })
        }
    }
    
    private var didSetupCustomSubviews: Bool = false
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if UserInformation.isUserFamilyHead {
            InAppPurchaseManager.initializeInAppPurchaseManager()
            InAppPurchaseManager.showPriceConsentIfNeeded()
        }
        
        CheckManager.checkForReleaseNotes()
        
        // Invocation of synchronizeNotificationAuthorization from willEnterForeground will only be accurate in conjuction with invocation of synchronizeNotificationAuthorization in viewIsAppearing of MainTabBarController. This makes it so every time Hound is opened, either from the background or from terminated, notifications are properly synced.
        // 1. Hound entering foreground from being terminated. willEnterForeground isn't called upon initial launch of Hound, only once Hound is sent to background then brought back to foreground, but viewIsAppearing MainTabBarController will catch as it's invoked once ServerSyncViewController is done loading
        // 2. Hound entering foreground after entering background. viewIsAppearing MainTabBarController won't catch as MainTabBarController's view isn't appearing anymore but willEnterForeground will catch any imbalance as it's called once app is loaded to foreground
        NotificationManager.synchronizeNotificationAuthorization()
        TimingManager.initializeReminderTimers(forDogManager: dogManager)
        
        guard didSetupCustomSubviews == false else {
            return
        }
        
        self.didSetupCustomSubviews = true
        
        // Adding this task to DispatchQueue delays it ever so slightly. This prevents an odd bug where the upperLine is incorrectly created and displayed, even through the subviews and safe area has been established properly.
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.addTabBarUpperLine(forIndex: self.selectedIndex)
        }
    }
    
    // MARK: - Functions
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // self.selectedIndex is incorrect. It is the the index before this new item was selected
        let newIndex = tabBar.items?.firstIndex(of: item)
        
        guard let newIndex = newIndex else {
            return
        }
        
        addTabBarUpperLine(forIndex: newIndex)
        
        // If any of the tabs were selected, we want to have the table views scroll back to the top
        if let referenceContentOffsetY = logsViewController?.logsTableViewController?.referenceContentOffsetY {
            logsViewController?.logsTableViewController?.tableView?.setContentOffset(CGPoint(x: 0.0, y: referenceContentOffsetY), animated: true)
        }
        if let referenceContentOffsetY = dogsViewController?.dogsTableViewController?.referenceContentOffsetY {
            dogsViewController?.dogsTableViewController?.tableView?.setContentOffset(CGPoint(x: 0.0, y: referenceContentOffsetY), animated: true)
        }
        
        // The user has selected the reminders tab and has not completed the reminders introduction page
        if newIndex == 1 && LocalConfiguration.localHasCompletedRemindersIntroductionViewController == false {
            
            if dogManager.hasCreatedReminder == false {
                // The family needs reminders, so we proceed as normal
                self.performSegueOnceInWindowHierarchy(segueIdentifier: "RemindersIntroductionViewController")
            }
            else {
                // The family doesn't need reminders, so just ask the user for notifications
                NotificationManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: true, completionHandler: nil)
                // We skipped the RemindersIntroductionViewController page but we still need to mark it as complete. As the user, in essence completed it by not being eligible for it. Additionally, otherwise, this requestNotificationAuthorization will keep getting reprompt.
                LocalConfiguration.localHasCompletedRemindersIntroductionViewController = true
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
