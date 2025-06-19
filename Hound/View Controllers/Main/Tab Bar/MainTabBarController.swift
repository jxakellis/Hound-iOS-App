//
//  MainTabBarController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class MainTabBarController: GeneralUITabBarController,
                                  ReminderTimingManagerDelegate,
                                  RemindersIntroductionViewControllerDelegate,
                                  ReminderAlarmManagerDelegate,
                                  LogsViewControllerDelegate,
                                  DogsViewControllerDelegate,
                                  SettingsPagesTableViewControllerDelegate,
                                  OfflineModeManagerDelegate {
    
    // MARK: LogsViewControllerDelegate && DogsViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)
    }
    
    // MARK: - ReminderAlarmManagerDelegate
    
    func didAddLog(sender: Sender, forDogUUID: UUID, forLog log: Log) {
        dogManager.findDog(forDogUUID: forDogUUID)?.dogLogs.addLog(forLog: log)
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    func didRemoveReminder(sender: Sender, forDogUUID: UUID, forReminderUUID: UUID) {
        let dogReminders = dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders
        dogReminders?.removeReminder(forReminderUUID: forReminderUUID)
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    // MARK: - ReminderAlarmManagerDelegate && ReminderTimingManagerDelegate
    
    func didAddReminder(sender: Sender, forDogUUID: UUID, forReminder reminder: Reminder) {
        dogManager.findDog(forDogUUID: forDogUUID)?.dogReminders.addReminder(forReminder: reminder)
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    // MARK: - Dog Manager
    
    private var dogManager: DogManager = DogManager.globalDogManager ?? DogManager()
    
    /// Sets dog manager; when the value changes, propagate timers and child VCs
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        DogManager.globalDogManager = dogManager
        
        // If not coming from ServerSyncViewController, initialize timers
        if (sender.localized is ServerSyncViewController) == false {
            ReminderTimingManager.initializeReminderTimers(forDogManager: dogManager)
        }
        // Propagate to DogsViewController if sender isn't DogsViewController
        if (sender.localized is DogsViewController) == false {
            dogsViewController.setDogManager(
                sender: Sender(origin: sender, localized: self),
                forDogManager: dogManager
            )
        }
        // Propagate to LogsViewController if sender isn't LogsViewController
        if (sender.localized is LogsViewController) == false {
            logsViewController.setDogManager(
                sender: Sender(origin: sender, localized: self),
                forDogManager: dogManager
            )
        }
    }
    
    // MARK: - Properties
    
    enum MainTabBarControllerIndexes: Int {
        case logs = 0
        case reminders = 1
        case settings = 2
    }
    
    private static var mainTabBarController: MainTabBarController?
    
    private let logsViewController = LogsViewController()
    private let dogsViewController = DogsViewController()
    private let settingsPagesTableViewController = SettingsPagesTableViewController()
    
    var tabBarUpperLineView: UIView?
    
    /// Returns true if this controller is currently in the view hierarchy
    static var isInViewHierarchy: Bool {
        return MainTabBarController.mainTabBarController?.viewIfLoaded?.window != nil
    }
    
    /// Toggled when a 'reminder' or 'log' notification arrives, indicating a refresh is needed
    static var shouldRefreshDogManager: Bool = false {
        didSet {
            guard shouldRefreshDogManager == true else { return }
            guard let mainTBC = MainTabBarController.mainTabBarController,
                  mainTBC.viewIfLoaded?.window != nil else {
                // Not visible; refresh when it appears
                return
            }
            DogsRequest.get(
                forErrorAlert: .automaticallyAlertForNone,
                forDogManager: mainTBC.dogManager
            ) { newDM, _, _ in
                MainTabBarController.shouldRefreshDogManager = false
                guard let newDM = newDM else { return }
                mainTBC.setDogManager(
                    sender: Sender(origin: self, localized: self),
                    forDogManager: newDM
                )
            }
        }
    }
    
    /// Toggled when a 'family' notification arrives, indicating a family‐level refresh
    static var shouldRefreshFamily: Bool = false {
        didSet {
            guard shouldRefreshFamily == true else { return }
            guard MainTabBarController.mainTabBarController?.viewIfLoaded?.window != nil else {
                // Not visible; refresh when it appears
                return
            }
            FamilyRequest.get(forErrorAlert: .automaticallyAlertForNone) { _, _ in
                MainTabBarController.shouldRefreshFamily = false
            }
        }
    }
    
    // MARK: - Main
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        tabBar.isTranslucent = true
        navigationController?.navigationBar.isTranslucent = true
        
        AppDelegate.generalLogger.notice("Version: \(UIApplication.appVersion)")
        
        logsViewController.setup(forDelegate: self)
        logsViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        
        dogsViewController.setup(forDelegate: self)
        dogsViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        
        settingsPagesTableViewController.setup(forDelegate: self)
        
        MainTabBarController.mainTabBarController = self
        ReminderTimingManager.delegate = self
        ReminderAlarmManager.delegate = self
        OfflineModeManager.shared.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if MainTabBarController.shouldRefreshDogManager {
            DogsRequest.get(
                forErrorAlert: .automaticallyAlertForNone,
                forDogManager: self.dogManager
            ) { newDM, _, _ in
                MainTabBarController.shouldRefreshDogManager = false
                guard let newDM = newDM else { return }
                self.setDogManager(
                    sender: Sender(origin: self, localized: self),
                    forDogManager: newDM
                )
            }
        }
        
        if MainTabBarController.shouldRefreshFamily {
            FamilyRequest.get(forErrorAlert: .automaticallyAlertForNone) { _, _ in
                MainTabBarController.shouldRefreshFamily = false
            }
        }
    }
    
    private var didSetupCustomSubviews: Bool = false
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if UserInformation.isUserFamilyHead {
            InAppPurchaseManager.initializeInAppPurchaseManager()
            InAppPurchaseManager.showPriceConsentIfNeeded()
        }
        
        ShowBonusInformationManager.showReleaseNotesBannerIfNeeded()
        
        // Synchronize notifications and timers on each appearance
        NotificationPermissionsManager.synchronizeNotificationAuthorization()
        ReminderTimingManager.initializeReminderTimers(forDogManager: dogManager)
        
        guard didSetupCustomSubviews == false else { return }
        didSetupCustomSubviews = true
        
        // Slight delay so tab item frames are valid before drawing underline
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.addTabBarUpperLine(forIndex: self.selectedIndex)
        }
    }
    
    // MARK: - Functions
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // selectedIndex is still the “old” index at this moment; compute new index manually
        guard let newIndex = tabBar.items?.firstIndex(of: item) else { return }
        addTabBarUpperLine(forIndex: newIndex)
        
        switch newIndex {
        case MainTabBarControllerIndexes.logs.rawValue:
            logsViewController.scrollLogsTableViewControllerToTop()
        case MainTabBarControllerIndexes.reminders.rawValue:
            dogsViewController.scrollDogsTableViewControllerToTop()
            
            if LocalConfiguration.localHasCompletedRemindersIntroductionViewController == false {
                if dogManager.hasCreatedReminder == false {
                    let introVC = RemindersIntroductionViewController()
                    introVC.setup(forDelegate: self, forDogManager: dogManager)
                    PresentationManager.enqueueViewController(introVC)
                }
                else {
                    // Not eligible; request notifications directly
                    NotificationPermissionsManager.requestNotificationAuthorization(
                        shouldAdviseUserBeforeRequestingNotifications: true,
                        completionHandler: nil
                    )
                    LocalConfiguration.localHasCompletedRemindersIntroductionViewController = true
                }
            }
        default:
            break
        }
    }
    
    private func addTabBarUpperLine(forIndex index: Int) {
        // Underline the selected tab item by accessing its underlying view
        guard let tabView = tabBar.items?[index].value(forKey: "view") as? UIView else {
            return
        }
        tabBarUpperLineView?.removeFromSuperview()
        
        let inset = tabView.frame.width * 0.15
        let lineFrame = CGRect(
            x: tabView.frame.minX + inset,
            y: tabView.frame.minY + 0.1,
            width: tabView.frame.width - (inset * 2),
            height: 2.0
        )
        let line = UIView(frame: lineFrame)
        line.backgroundColor = .systemBlue
        tabBar.addSubview(line)
        tabBarUpperLineView = line
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        if let mainTabBar = self.value(forKey: "tabBar") as? UITabBar,
           !(mainTabBar is MainTabBar) {
            let customTabBar = MainTabBar()
            self.setValue(customTabBar, forKey: "tabBar")
        }
        
        view.backgroundColor = .secondarySystemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        let logsNavController = {
            let navController = UINavigationController(rootViewController: logsViewController)
            navController.navigationBar.barTintColor = .systemBackground
            navController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20),
                NSAttributedString.Key.foregroundColor: UIColor.systemBlue
            ]
            navController.navigationBar.isHidden = true
            navController.tabBarItem = UITabBarItem(
                title: "Logs",
                image: UIImage(systemName: "list.bullet.rectangle"),
                tag: MainTabBarControllerIndexes.logs.rawValue
            )
            
            return navController
        }()
        
        let dogsNavController = {
            let navController = UINavigationController(rootViewController: dogsViewController)
            navController.navigationBar.barTintColor = .systemBackground
            navController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20),
                NSAttributedString.Key.foregroundColor: UIColor.systemBlue
            ]
            navController.navigationBar.isHidden = true
            navController.tabBarItem = UITabBarItem(
                title: "Reminders",
                image: UIImage(named: "blackPaw"),
                tag: MainTabBarControllerIndexes.reminders.rawValue
            )
            
            return navController
        }()
        
        let settingsNavController = {
            let navController = UINavigationController(rootViewController: settingsPagesTableViewController)
            navController.navigationBar.barTintColor = .systemBackground
            navController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20),
                NSAttributedString.Key.foregroundColor: UIColor.systemBlue
            ]
            navController.navigationBar.isHidden = true
            navController.tabBarItem = UITabBarItem(
                title: "Settings",
                image: UIImage(systemName: "gearshape"),
                tag: MainTabBarControllerIndexes.settings.rawValue
            )
            
            return navController
        }()
        
        self.viewControllers = [logsNavController, dogsNavController, settingsNavController]
    }
    
    override func setupConstraints() {
        super.setupConstraints()
    }
}
