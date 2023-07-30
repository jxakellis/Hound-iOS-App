//
//  SettingsNotificationsTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

private enum SettingsNotificationsTableViewCells: String, CaseIterable {
    case SettingsNotificationsUseNotificationsTableViewCell
    case SettingsNotificationsSilentModeTableViewCell
    case SettingsNotificationsCatagoriesTableViewCells
    case SettingsNotificationsAlarmsTableViewController
}

final class SettingsNotificationsTableViewController: UITableViewController, SettingsNotificationsUseNotificationsTableViewCellDelegate {
    
    // MARK: - SettingsNotificationsUseNotificationsTableViewCellDelegate
    
    func didToggleIsNotificationEnabled() {
        synchronizeAllIsEnabled()
    }
    
    // MARK: - Properties
    
    private(set) var settingsNotificationsCatagoriesTableViewController: SettingsNotificationsCatagoriesTableViewController?
    
    private(set) var settingsNotificationsAlarmsTableViewController: SettingsNotificationsAlarmsTableViewController?
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dummyTableTableHeaderViewHeight = 100.0
        // Adding a tableHeaderView prevents section headers from sticking and floating at the top of the page when we scroll up. This is because we are basically adding a large blank space to the top of the screen, allowing a space for the header to scroll into
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyTableTableHeaderViewHeight))
        tableView.contentInset = UIEdgeInsets(top: -dummyTableTableHeaderViewHeight, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .didDismissForSettingsPageViewController, object: self)
    }
    
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SettingsNotificationsTableHeaderView()
        
        headerView.setup(forTitle: "Notifications")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SettingsNotificationsTableHeaderView.cellHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // We will be indexing SettingsNotificationsCatagoriesTableViewCells.allCases for the cell identifier, therefore make sure the cell is within a defined range
        guard indexPath.row < SettingsNotificationsTableViewCells.allCases.count else {
            return UITableViewCell()
        }
        
        let identifierCase = SettingsNotificationsTableViewCells.allCases[indexPath.row]
        let identifier = identifierCase.rawValue
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if let cell = cell as? SettingsNotificationsUseNotificationsTableViewCell {
            cell.delegate = self
        }
        
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsNotificationsCatagoriesTableViewController = segue.destination as? SettingsNotificationsCatagoriesTableViewController {
            self.settingsNotificationsCatagoriesTableViewController = settingsNotificationsCatagoriesTableViewController
        }
        else if let settingsNotificationsAlarmsTableViewController = segue.destination as? SettingsNotificationsAlarmsTableViewController {
            self.settingsNotificationsAlarmsTableViewController = settingsNotificationsAlarmsTableViewController
        }
    }

}
