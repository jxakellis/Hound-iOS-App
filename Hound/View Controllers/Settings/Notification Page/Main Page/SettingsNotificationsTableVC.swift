//
//  SettingsNotificationsTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

private enum SettingsNotificationsTableViewCells: String, CaseIterable {
    case SettingsNotificationsUseNotificationsTableViewCell
    case SettingsNotificationsSilentModeTableViewCell
    case SettingsNotificationsCatagoriesTableViewCells
    case SettingsNotificationsAlarmsTableViewController
}

class SettingsNotificationsTableViewController: UITableViewController, SettingsNotificationsUseNotificationsTableViewCellDelegate {
    
    // MARK: - SettingsNotificationsUseNotificationsTableViewCellDelegate
    
    func didToggleIsNotificationEnabled() {
        synchronizeAllIsEnabled()
    }
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.bounces = false
        tableView.separatorColor = .clear
    }
    
    // MARK: - Properties
    
    private var settingsNotificationsCatagoriesTableViewController: SettingsNotificationsCatagoriesTableViewController?
    
    private var settingsNotificationsAlarmsTableViewController: SettingsNotificationsAlarmsTableViewController?
    
    // MARK: - Functions
    
    /// Goes through all notification cells to synchronize their isEnabled to represent the state of isNotificationEnabled
    func synchronizeAllIsEnabled() {
        // useNotificationsCell is always isEnabled true
        
        if let silentModeRow = SettingsNotificationsTableViewCells.allCases.firstIndex(of: SettingsNotificationsTableViewCells.SettingsNotificationsSilentModeTableViewCell) {
            let silentModeCellIndexPath = IndexPath(row: silentModeRow, section: 0)
            if let silentModeCell = tableView(tableView, cellForRowAt: silentModeCellIndexPath) as? SettingsNotificationsSilentModeTableViewCell {
                silentModeCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [silentModeCellIndexPath], with: .none)
            }
        }
        
        settingsNotificationsCatagoriesTableViewController?.synchronizeAllIsEnabled()
        
        settingsNotificationsAlarmsTableViewController?.synchronizeAllIsEnabled()
    }
    
    /// Goes through all notification cells to synchronize their values to represent what is stored
    func synchronizeAllValues(animated: Bool) {
        synchronizeAllIsEnabled()
        
        if let useNotificationsRow = SettingsNotificationsTableViewCells.allCases.firstIndex(of: SettingsNotificationsTableViewCells.SettingsNotificationsUseNotificationsTableViewCell) {
            let useNotificationsIndexPath = IndexPath(row: useNotificationsRow, section: 0)
            if let useNotificationsCell = tableView(tableView, cellForRowAt: useNotificationsIndexPath) as? SettingsNotificationsUseNotificationsTableViewCell {
                useNotificationsCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [useNotificationsIndexPath], with: .none)
            }
        }
        
        if let silentModeRow = SettingsNotificationsTableViewCells.allCases.firstIndex(of: SettingsNotificationsTableViewCells.SettingsNotificationsSilentModeTableViewCell) {
            let silentModeCellIndexPath = IndexPath(row: silentModeRow, section: 0)
            if let silentModeCell = tableView(tableView, cellForRowAt: silentModeCellIndexPath) as? SettingsNotificationsSilentModeTableViewCell {
                silentModeCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [silentModeCellIndexPath], with: .none)
            }
        }
        
        settingsNotificationsCatagoriesTableViewController?.synchronizeAllValues(animated: animated)
        
        settingsNotificationsAlarmsTableViewController?.synchronizeAllValues(animated: animated)
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsNotificationsTableViewCells.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // We will be indexing SettingsNotificationsCatagoriesTableViewCells.allCases for the cell identifier, therefore make sure the cell is within a defined range
        guard indexPath.row < SettingsNotificationsTableViewCells.allCases.count else {
            return UITableViewCell()
        }
        
        let identifierCase = SettingsNotificationsTableViewCells.allCases[indexPath.row]
        let identifier = identifierCase.rawValue
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        cell.separatorInset = .zero
        cell.selectionStyle = (identifierCase == .SettingsNotificationsCatagoriesTableViewCells || identifierCase == .SettingsNotificationsAlarmsTableViewController) ? .default : .none
        
        switch identifierCase {
        case .SettingsNotificationsUseNotificationsTableViewCell:
            if let customCell = cell as? SettingsNotificationsUseNotificationsTableViewCell {
                customCell.delegate = self
                customCell.synchronizeValues(animated: false)
            }
        case .SettingsNotificationsSilentModeTableViewCell:
            if let customCell = cell as? SettingsNotificationsSilentModeTableViewCell {
                customCell.synchronizeValues(animated: false)
            }
        case .SettingsNotificationsCatagoriesTableViewCells:
            break
        case .SettingsNotificationsAlarmsTableViewController:
            break
        }
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsNotificationsCatagoriesTableViewController = segue.destination as? SettingsNotificationsCatagoriesTableViewController {
            self.settingsNotificationsCatagoriesTableViewController = settingsNotificationsCatagoriesTableViewController
        }
        else if let settingsNotificationsAlarmsTableViewController = segue.destination as? SettingsNotificationsAlarmsTableViewController {
            self.settingsNotificationsAlarmsTableViewController = settingsNotificationsAlarmsTableViewController
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
