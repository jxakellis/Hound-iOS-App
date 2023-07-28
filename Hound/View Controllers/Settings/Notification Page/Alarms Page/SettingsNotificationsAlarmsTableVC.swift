//
//  SettingsNotificationsAlarmsTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

private enum SettingsNotificationsAlarmsTableViewCells: String, CaseIterable {
    case SettingsNotificationsAlarmsLoudNotificationsTableViewCell
    case SettingsNotificationsAlarmsSnoozeLengthTableViewCell
    case SettingsNotificationsAlarmsNotificationSoundsTableViewCell
}

class SettingsNotificationsAlarmsTableViewController: UITableViewController {
    
    // TO DO NOW adapt page to new style. add x button to top right.
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.bounces = false
        tableView.separatorColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioManager.stopAudio()
    }
    
    // MARK: - Functions
    
    /// Goes through all notification cells to synchronize their isEnabled to represent the state of isNotificationEnabled
    func synchronizeAllIsEnabled() {
        if let loudNotificationsRow = SettingsNotificationsAlarmsTableViewCells.allCases.firstIndex(of: SettingsNotificationsAlarmsTableViewCells.SettingsNotificationsAlarmsLoudNotificationsTableViewCell) {
            let loudNotificationsIndexPath = IndexPath(row: loudNotificationsRow, section: 0)
            if let loudNotificationsCell = tableView(tableView, cellForRowAt: loudNotificationsIndexPath) as? SettingsNotificationsAlarmsLoudNotificationsTableViewCell {
                loudNotificationsCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [loudNotificationsIndexPath], with: .none)
            }
        }
        
        if let snoozeLengthRow = SettingsNotificationsAlarmsTableViewCells.allCases.firstIndex(of: SettingsNotificationsAlarmsTableViewCells.SettingsNotificationsAlarmsSnoozeLengthTableViewCell) {
            let snoozeLengthIndexPath = IndexPath(row: snoozeLengthRow, section: 0)
            if let snoozeLengthCell = tableView(tableView, cellForRowAt: snoozeLengthIndexPath) as? SettingsNotificationsAlarmsSnoozeLengthTableViewCell {
                snoozeLengthCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [snoozeLengthIndexPath], with: .none)
            }
        }
        
        if let notificationSoundRow = SettingsNotificationsAlarmsTableViewCells.allCases.firstIndex(of: SettingsNotificationsAlarmsTableViewCells.SettingsNotificationsAlarmsNotificationSoundsTableViewCell) {
            let notificationSoundIndexPath = IndexPath(row: notificationSoundRow, section: 0)
            if let notificationSoundCell = tableView(tableView, cellForRowAt: notificationSoundIndexPath) as? SettingsNotificationsAlarmsNotificationSoundsTableViewCell {
                notificationSoundCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [notificationSoundIndexPath], with: .none)
            }
        }
        
    }
    
    /// Goes through all notification cells to synchronize their values to represent what is stored
    func synchronizeAllValues(animated: Bool) {
        synchronizeAllIsEnabled()
        
        if let loudNotificationsRow = SettingsNotificationsAlarmsTableViewCells.allCases.firstIndex(of: SettingsNotificationsAlarmsTableViewCells.SettingsNotificationsAlarmsLoudNotificationsTableViewCell) {
            let loudNotificationsIndexPath = IndexPath(row: loudNotificationsRow, section: 0)
            if let loudNotificationsCell = tableView(tableView, cellForRowAt: loudNotificationsIndexPath) as? SettingsNotificationsAlarmsLoudNotificationsTableViewCell {
                loudNotificationsCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [loudNotificationsIndexPath], with: .none)
            }
        }
        
        if let snoozeLengthRow = SettingsNotificationsAlarmsTableViewCells.allCases.firstIndex(of: SettingsNotificationsAlarmsTableViewCells.SettingsNotificationsAlarmsSnoozeLengthTableViewCell) {
            let snoozeLengthIndexPath = IndexPath(row: snoozeLengthRow, section: 0)
            if let snoozeLengthCell = tableView(tableView, cellForRowAt: snoozeLengthIndexPath) as? SettingsNotificationsAlarmsSnoozeLengthTableViewCell {
                snoozeLengthCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [snoozeLengthIndexPath], with: .none)
            }
        }
        
        if let notificationSoundRow = SettingsNotificationsAlarmsTableViewCells.allCases.firstIndex(of: SettingsNotificationsAlarmsTableViewCells.SettingsNotificationsAlarmsNotificationSoundsTableViewCell) {
            let notificationSoundIndexPath = IndexPath(row: notificationSoundRow, section: 0)
            if let notificationSoundCell = tableView(tableView, cellForRowAt: notificationSoundIndexPath) as? SettingsNotificationsAlarmsNotificationSoundsTableViewCell {
                notificationSoundCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [notificationSoundIndexPath], with: .none)
            }
        }
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsNotificationsAlarmsTableViewCells.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // We will be indexing SettingsNotificationsCatagoriesTableViewCells.allCases for the cell identifier, therefore make sure the cell is within a defined range
        guard indexPath.row < SettingsNotificationsAlarmsTableViewCells.allCases.count else {
            return UITableViewCell()
        }
        
        let identifierCase = SettingsNotificationsAlarmsTableViewCells.allCases[indexPath.row]
        let identifier = identifierCase.rawValue
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        cell.separatorInset = .zero
        cell.selectionStyle = .none
        
        return cell
    }

}
