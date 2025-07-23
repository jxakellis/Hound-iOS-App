//
//  SettingsNotifsAlarmsVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsAlarmsVC: HoundViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties

    private lazy var tableView = {
        let tableView = HoundTableView(style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        
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
        
        return tableView
    }()
    
    private let settingsNotifsCategoriesTVCReuseIdentifiers = [
        SettingsNotifsAlarmsLoudNotificationsTVC.reuseIdentifier,
        SettingsNotifsAlarmsSnoozeLengthTVC.reuseIdentifier,
        SettingsNotifsAlarmsNotificationSoundsTVC.reuseIdentifier
    ]

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioManager.stopAudio()
    }

    // MARK: - Functions

    func synchronizeAllIsEnabled() {
        for index in settingsNotifsCategoriesTVCReuseIdentifiers.indices {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }

    func synchronizeAllValues(animated: Bool) {
        synchronizeAllIsEnabled()
        for index in settingsNotifsCategoriesTVCReuseIdentifiers.indices {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsNotifsCategoriesTVCReuseIdentifiers.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = PageSheetHeaderFooterView()
        headerView.setup(forTitle: "Alarms")
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < settingsNotifsCategoriesTVCReuseIdentifiers.count else {
            return HoundTableViewCell()
        }
        let identifier = settingsNotifsCategoriesTVCReuseIdentifiers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        return cell
    }

    // MARK: - Setup Elements

    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBackground
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        view.addSubview(tableView)
    }

    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
