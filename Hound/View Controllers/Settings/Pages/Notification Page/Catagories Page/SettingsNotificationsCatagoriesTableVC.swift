//
//  SettingsNotificationsCatagoriesTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

private enum SettingsNotificationsCatagoriesTableViewCells: String, CaseIterable {
    case SettingsNotificationsCatagoriesAccountTableViewCell
    case SettingsNotificationsCatagoriesFamilyTableViewCell
    case SettingsNotificationsCatagoriesLogTableViewCell
    case SettingsNotificationsCatagoriesReminderTableViewCell
}

class SettingsNotificationsCatagoriesTableViewController: UITableViewController {
    
    // MARK: - Functions
    
    /// Goes through all notification cells to synchronize their isEnabled to represent the state of isNotificationEnabled
    func synchronizeAllIsEnabled() {
        // NO-OP class SettingsNotificationsCatagoriesAccountTableViewCell
        
        // NO-OP class SettingsNotificationsCatagoriesFamilyTableViewCell
        
        if let logRow = SettingsNotificationsCatagoriesTableViewCells.allCases.firstIndex(of: SettingsNotificationsCatagoriesTableViewCells.SettingsNotificationsCatagoriesLogTableViewCell) {
            let logIndexPath = IndexPath(row: logRow, section: 0)
            if let logCell = tableView(tableView, cellForRowAt: logIndexPath) as? SettingsNotificationsCatagoriesLogTableViewCell {
                logCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [logIndexPath], with: .none)
            }
        }
        
        if let reminderRow = SettingsNotificationsCatagoriesTableViewCells.allCases.firstIndex(of: SettingsNotificationsCatagoriesTableViewCells.SettingsNotificationsCatagoriesReminderTableViewCell) {
            let reminderIndexPath = IndexPath(row: reminderRow, section: 0)
            if let reminderCell = tableView(tableView, cellForRowAt: reminderIndexPath) as? SettingsNotificationsCatagoriesReminderTableViewCell {
                reminderCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [reminderIndexPath], with: .none)
            }
        }
    }
    
    /// Goes through all notification cells to synchronize their values to represent what is stored
    func synchronizeAllValues(animated: Bool) {
        synchronizeAllIsEnabled()
        
        // NO-OP class SettingsNotificationsCatagoriesAccountTableViewCell
        
        // NO-OP class SettingsNotificationsCatagoriesFamilyTableViewCell
        
        if let logRow = SettingsNotificationsCatagoriesTableViewCells.allCases.firstIndex(of: SettingsNotificationsCatagoriesTableViewCells.SettingsNotificationsCatagoriesLogTableViewCell) {
            let logIndexPath = IndexPath(row: logRow, section: 0)
            if let logCell = tableView(tableView, cellForRowAt: logIndexPath) as? SettingsNotificationsCatagoriesLogTableViewCell {
                logCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [logIndexPath], with: .none)
            }
        }
        
        if let reminderRow = SettingsNotificationsCatagoriesTableViewCells.allCases.firstIndex(of: SettingsNotificationsCatagoriesTableViewCells.SettingsNotificationsCatagoriesReminderTableViewCell) {
            let reminderIndexPath = IndexPath(row: reminderRow, section: 0)
            if let reminderCell = tableView(tableView, cellForRowAt: reminderIndexPath) as? SettingsNotificationsCatagoriesReminderTableViewCell {
                reminderCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [reminderIndexPath], with: .none)
            }
        }
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsNotificationsCatagoriesTableViewCells.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // We will be indexing SettingsNotificationsCatagoriesTableViewCells.allCases for the cell identifier, therefore make sure the cell is within a defined range
        guard indexPath.row < SettingsNotificationsCatagoriesTableViewCells.allCases.count else {
            return UITableViewCell()
        }
        
        let identifierCase = SettingsNotificationsCatagoriesTableViewCells.allCases[indexPath.row]
        let identifier = identifierCase.rawValue
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        return cell
    }
}
