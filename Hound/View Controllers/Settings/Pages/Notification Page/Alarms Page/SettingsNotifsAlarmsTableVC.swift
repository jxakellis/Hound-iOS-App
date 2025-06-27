//
//  SettingsNotifsAlarmsTableVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO VERIFY UI
final class SettingsNotifsAlarmsTableVC: GeneralUITableViewController {
    
    // MARK: - Properties
    
    private let settingsNotifsCategoriesTVCReuseIdentifiers = [SettingsNotifsAlarmsLoudNotificationsTVC.reuseIdentifier,
                                                               SettingsNotifsAlarmsSnoozeLengthTVC.reuseIdentifier,
                                                               SettingsNotifsAlarmsNotificationSoundsTVC.reuseIdentifier
    ]
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        self.enableDummyHeaderView = true
        
        settingsNotifsCategoriesTVCReuseIdentifiers.forEach { settingsNotifsTVCReuseIdentifier in
            switch settingsNotifsTVCReuseIdentifier {
            case SettingsNotifsAlarmsLoudNotificationsTVC.reuseIdentifier:
                tableView.register(SettingsNotifsAlarmsLoudNotificationsTVC.self, forCellReuseIdentifier: SettingsNotifsAlarmsLoudNotificationsTVC.reuseIdentifier)
            case SettingsNotifsAlarmsSnoozeLengthTVC.reuseIdentifier:
                tableView.register(SettingsNotifsAlarmsSnoozeLengthTVC.self, forCellReuseIdentifier: SettingsNotifsAlarmsSnoozeLengthTVC.reuseIdentifier)
            case SettingsNotifsAlarmsNotificationSoundsTVC.reuseIdentifier:
                tableView.register(SettingsNotifsAlarmsNotificationSoundsTVC.self, forCellReuseIdentifier: SettingsNotifsAlarmsNotificationSoundsTVC.reuseIdentifier)
            default: fatalError("You must register all table view cells")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioManager.stopAudio()
    }
    
    // MARK: - Functions
    
    /// Goes through all notification cells to synchronize their isEnabled to represent the state of isNotificationEnabled
    func synchronizeAllIsEnabled() {
        if let loudNotificationsRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsAlarmsLoudNotificationsTVC.reuseIdentifier) {
            let loudNotificationsIndexPath = IndexPath(row: loudNotificationsRow, section: 0)
            if let loudNotificationsCell = tableView(tableView, cellForRowAt: loudNotificationsIndexPath) as? SettingsNotifsAlarmsLoudNotificationsTVC {
                loudNotificationsCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [loudNotificationsIndexPath], with: .none)
            }
        }
        
        if let snoozeLengthRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsAlarmsSnoozeLengthTVC.reuseIdentifier) {
            let snoozeLengthIndexPath = IndexPath(row: snoozeLengthRow, section: 0)
            if let snoozeLengthCell = tableView(tableView, cellForRowAt: snoozeLengthIndexPath) as? SettingsNotifsAlarmsSnoozeLengthTVC {
                snoozeLengthCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [snoozeLengthIndexPath], with: .none)
            }
        }
        
        if let notificationSoundRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsAlarmsNotificationSoundsTVC.reuseIdentifier) {
            let notificationSoundIndexPath = IndexPath(row: notificationSoundRow, section: 0)
            if let notificationSoundCell = tableView(tableView, cellForRowAt: notificationSoundIndexPath) as? SettingsNotifsAlarmsNotificationSoundsTVC {
                notificationSoundCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [notificationSoundIndexPath], with: .none)
            }
        }
        
    }
    
    /// Goes through all notification cells to synchronize their values to represent what is stored
    func synchronizeAllValues(animated: Bool) {
        synchronizeAllIsEnabled()
        
        if let loudNotificationsRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsAlarmsLoudNotificationsTVC.reuseIdentifier) {
            let loudNotificationsIndexPath = IndexPath(row: loudNotificationsRow, section: 0)
            if let loudNotificationsCell = tableView(tableView, cellForRowAt: loudNotificationsIndexPath) as? SettingsNotifsAlarmsLoudNotificationsTVC {
                loudNotificationsCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [loudNotificationsIndexPath], with: .none)
            }
        }
        
        if let snoozeLengthRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsAlarmsSnoozeLengthTVC.reuseIdentifier) {
            let snoozeLengthIndexPath = IndexPath(row: snoozeLengthRow, section: 0)
            if let snoozeLengthCell = tableView(tableView, cellForRowAt: snoozeLengthIndexPath) as? SettingsNotifsAlarmsSnoozeLengthTVC {
                snoozeLengthCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [snoozeLengthIndexPath], with: .none)
            }
        }
        
        if let notificationSoundRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsAlarmsNotificationSoundsTVC.reuseIdentifier) {
            let notificationSoundIndexPath = IndexPath(row: notificationSoundRow, section: 0)
            if let notificationSoundCell = tableView(tableView, cellForRowAt: notificationSoundIndexPath) as? SettingsNotifsAlarmsNotificationSoundsTVC {
                notificationSoundCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [notificationSoundIndexPath], with: .none)
            }
        }
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsNotifsCategoriesTVCReuseIdentifiers.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SettingsNotifsTableHeaderView()
        
        headerView.setup(forTitle: "Alarms")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // We will be indexing SettingsNotifsCategoriesTVCs.allCases for the cell identifier, therefore make sure the cell is within a defined range
        guard indexPath.row < settingsNotifsCategoriesTVCReuseIdentifiers.count else {
            return GeneralUITableViewCell()
        }
        
        let identifier = settingsNotifsCategoriesTVCReuseIdentifiers[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        return cell
    }
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
        ])
    }
}
