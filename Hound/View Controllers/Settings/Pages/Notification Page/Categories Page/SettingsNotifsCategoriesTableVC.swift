//
//  SettingsNotifsCategoriesTableVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO VERIFY UI
final class SettingsNotifsCategoriesTableVC: GeneralUIViewController {
    
    // MARK: - Properties
    
    private let tableView = GeneralUITableView()
    private let settingsNotifsCategoriesTVCReuseIdentifiers = [SettingsNotifsCategoriesAccountTVC.reuseIdentifier,
                                                               SettingsNotifsCategoriesFamilyTVC.reuseIdentifier,
                                                               SettingsNotifsCategoriesLogTVC.reuseIdentifier,
                                                               SettingsNotifsCategoriesReminderTVC.reuseIdentifier
    ]
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        self.enableDummyHeaderView = true
        
        settingsNotifsCategoriesTVCReuseIdentifiers.forEach { settingsNotifsTVCReuseIdentifier in
            switch settingsNotifsTVCReuseIdentifier {
            case SettingsNotifsCategoriesAccountTVC.reuseIdentifier:
                tableView.register(SettingsNotifsCategoriesAccountTVC.self, forCellReuseIdentifier: SettingsNotifsCategoriesAccountTVC.reuseIdentifier)
            case SettingsNotifsCategoriesFamilyTVC.reuseIdentifier:
                tableView.register(SettingsNotifsCategoriesFamilyTVC.self, forCellReuseIdentifier: SettingsNotifsCategoriesFamilyTVC.reuseIdentifier)
            case SettingsNotifsCategoriesLogTVC.reuseIdentifier:
                tableView.register(SettingsNotifsCategoriesLogTVC.self, forCellReuseIdentifier: SettingsNotifsCategoriesLogTVC.reuseIdentifier)
            case SettingsNotifsCategoriesReminderTVC.reuseIdentifier:
                tableView.register(SettingsNotifsCategoriesReminderTVC.self, forCellReuseIdentifier: SettingsNotifsCategoriesReminderTVC.reuseIdentifier)
            default: fatalError("You must register all table view cells")
            }
        }
    }
    
    // MARK: - Functions
    
    /// Goes through all notification cells to synchronize their isEnabled to represent the state of isNotificationEnabled
    func synchronizeAllIsEnabled() {
        // NO-OP class SettingsNotifsCategoriesAccountTVC
        
        // NO-OP class SettingsNotifsCategoriesFamilyTVC
        
        if let logRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsCategoriesLogTVC.reuseIdentifier) {
            let logIndexPath = IndexPath(row: logRow, section: 0)
            if let logCell = tableView(tableView, cellForRowAt: logIndexPath) as? SettingsNotifsCategoriesLogTVC {
                logCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [logIndexPath], with: .none)
            }
        }
        
        if let reminderRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsCategoriesReminderTVC.reuseIdentifier) {
            let reminderIndexPath = IndexPath(row: reminderRow, section: 0)
            if let reminderCell = tableView(tableView, cellForRowAt: reminderIndexPath) as? SettingsNotifsCategoriesReminderTVC {
                reminderCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [reminderIndexPath], with: .none)
            }
        }
    }
    
    /// Goes through all notification cells to synchronize their values to represent what is stored
    func synchronizeAllValues(animated: Bool) {
        synchronizeAllIsEnabled()
        
        // NO-OP class SettingsNotifsCategoriesAccountTVC
        
        // NO-OP class SettingsNotifsCategoriesFamilyTVC
        
        if let logRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsCategoriesLogTVC.reuseIdentifier) {
            let logIndexPath = IndexPath(row: logRow, section: 0)
            if let logCell = tableView(tableView, cellForRowAt: logIndexPath) as? SettingsNotifsCategoriesLogTVC {
                logCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [logIndexPath], with: .none)
            }
        }
        
        if let reminderRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsCategoriesReminderTVC.reuseIdentifier) {
            let reminderIndexPath = IndexPath(row: reminderRow, section: 0)
            if let reminderCell = tableView(tableView, cellForRowAt: reminderIndexPath) as? SettingsNotifsCategoriesReminderTVC {
                reminderCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [reminderIndexPath], with: .none)
            }
        }
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsNotifsCategoriesTVCReuseIdentifiers.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SettingsNotifsTableHeaderView()
        
        headerView.setup(forTitle: "Categories")
        
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
