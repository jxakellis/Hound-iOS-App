//
//  SettingsNotifsAlarmsTableVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

private enum SettingsNotifsAlarmsTVCs: String, CaseIterable {
    case SettingsNotifsAlarmsLoudNotificationsTVC
    case SettingsNotifsAlarmsSnoozeLengthTVC
    case SettingsNotifsAlarmsNotificationSoundsTVC
}

final class SettingsNotifsAlarmsTableVC: GeneralUITableViewController {

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true

        let dummyTableTableHeaderViewHeight = 100.0
        // Adding a tableHeaderView prevents section headers from sticking and floating at the top of the page when we scroll up. This is because we are basically adding a large blank space to the top of the screen, allowing a space for the header to scroll into
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyTableTableHeaderViewHeight))
        tableView.contentInset = UIEdgeInsets(top: -dummyTableTableHeaderViewHeight, left: 0, bottom: 0, right: 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioManager.stopAudio()
    }

    // MARK: - Functions

    /// Goes through all notification cells to synchronize their isEnabled to represent the state of isNotificationEnabled
    func synchronizeAllIsEnabled() {
        if let loudNotificationsRow = SettingsNotifsAlarmsTVCs.allCases.firstIndex(of: SettingsNotifsAlarmsTVCs.SettingsNotifsAlarmsLoudNotificationsTVC) {
            let loudNotificationsIndexPath = IndexPath(row: loudNotificationsRow, section: 0)
            if let loudNotificationsCell = tableView(tableView, cellForRowAt: loudNotificationsIndexPath) as? SettingsNotifsAlarmsLoudNotificationsTVC {
                loudNotificationsCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [loudNotificationsIndexPath], with: .none)
            }
        }

        if let snoozeLengthRow = SettingsNotifsAlarmsTVCs.allCases.firstIndex(of: SettingsNotifsAlarmsTVCs.SettingsNotifsAlarmsSnoozeLengthTVC) {
            let snoozeLengthIndexPath = IndexPath(row: snoozeLengthRow, section: 0)
            if let snoozeLengthCell = tableView(tableView, cellForRowAt: snoozeLengthIndexPath) as? SettingsNotifsAlarmsSnoozeLengthTVC {
                snoozeLengthCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [snoozeLengthIndexPath], with: .none)
            }
        }

        if let notificationSoundRow = SettingsNotifsAlarmsTVCs.allCases.firstIndex(of: SettingsNotifsAlarmsTVCs.SettingsNotifsAlarmsNotificationSoundsTVC) {
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

        if let loudNotificationsRow = SettingsNotifsAlarmsTVCs.allCases.firstIndex(of: SettingsNotifsAlarmsTVCs.SettingsNotifsAlarmsLoudNotificationsTVC) {
            let loudNotificationsIndexPath = IndexPath(row: loudNotificationsRow, section: 0)
            if let loudNotificationsCell = tableView(tableView, cellForRowAt: loudNotificationsIndexPath) as? SettingsNotifsAlarmsLoudNotificationsTVC {
                loudNotificationsCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [loudNotificationsIndexPath], with: .none)
            }
        }

        if let snoozeLengthRow = SettingsNotifsAlarmsTVCs.allCases.firstIndex(of: SettingsNotifsAlarmsTVCs.SettingsNotifsAlarmsSnoozeLengthTVC) {
            let snoozeLengthIndexPath = IndexPath(row: snoozeLengthRow, section: 0)
            if let snoozeLengthCell = tableView(tableView, cellForRowAt: snoozeLengthIndexPath) as? SettingsNotifsAlarmsSnoozeLengthTVC {
                snoozeLengthCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [snoozeLengthIndexPath], with: .none)
            }
        }

        if let notificationSoundRow = SettingsNotifsAlarmsTVCs.allCases.firstIndex(of: SettingsNotifsAlarmsTVCs.SettingsNotifsAlarmsNotificationSoundsTVC) {
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
        SettingsNotifsAlarmsTVCs.allCases.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SettingsNotifsTableHeaderV()

        headerView.setup(forTitle: "Alarms")

        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        SettingsNotifsTableHeaderV.cellHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // We will be indexing SettingsNotifsCategoriesTVCs.allCases for the cell identifier, therefore make sure the cell is within a defined range
        guard indexPath.row < SettingsNotifsAlarmsTVCs.allCases.count else {
            return GeneralUITableViewCell()
        }

        let identifierCase = SettingsNotifsAlarmsTVCs.allCases[indexPath.row]
        let identifier = identifierCase.rawValue

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
