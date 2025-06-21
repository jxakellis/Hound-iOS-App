//
//  SettingsNotifsTableVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsTableVC: GeneralUITableViewController, SettingsNotifsUseNotificationsTVCDelegate {
    
    // MARK: - SettingsNotifsUseNotificationsTVCDelegate
    
    func didToggleIsNotificationEnabled() {
        synchronizeAllIsEnabled()
    }
    
    // MARK: - Properties
    
    private static var settingsNotifsTableVC: SettingsNotifsTableVC?
    
    private var settingsNotifsCategoriesTableVC: SettingsNotifsCategoriesTableVC?
    
    private var settingsNotifsAlarmsTableVC: SettingsNotifsAlarmsTableVC?
    
    private let settingsNotifsTVCReuseIdentifiers = [SettingsNotifsUseNotificationsTVC.reuseIdentifier,
                                                     SettingsNotifsSilentModeTVC.reuseIdentifier,
                                                     SettingsNotifsCategoriesTVC.reuseIdentifier,
                                                     SettingsNotifsAlarmsTVC.reuseIdentifier
    ]
    
    // MARK: - Main
    
    convenience init() {
        self.init(style: .plain)
    }
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        settingsNotifsTVCReuseIdentifiers.forEach { settingsNotifsTVCReuseIdentifier in
            switch settingsNotifsTVCReuseIdentifier {
            case SettingsNotifsUseNotificationsTVC.reuseIdentifier:
                tableView.register(SettingsNotifsUseNotificationsTVC.self, forCellReuseIdentifier: SettingsNotifsUseNotificationsTVC.reuseIdentifier)
            case SettingsNotifsSilentModeTVC.reuseIdentifier:
                tableView.register(SettingsNotifsSilentModeTVC.self, forCellReuseIdentifier: SettingsNotifsSilentModeTVC.reuseIdentifier)
            case SettingsNotifsCategoriesTVC.reuseIdentifier:
                tableView.register(SettingsNotifsCategoriesTVC.self, forCellReuseIdentifier: SettingsNotifsCategoriesTVC.reuseIdentifier)
            case SettingsNotifsAlarmsTVC.reuseIdentifier:
                tableView.register(SettingsNotifsAlarmsTVC.self, forCellReuseIdentifier: SettingsNotifsAlarmsTVC.reuseIdentifier)
            default: break
            }
        }
        
        SettingsNotifsTableVC.settingsNotifsTableVC = self
        
        let dummyTableTableHeaderViewHeight = 100.0
        // Adding a tableHeaderView prevents section headers from sticking and floating at the top of the page when we scroll up. This is because we are basically adding a large blank space to the top of the screen, allowing a space for the header to scroll into
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyTableTableHeaderViewHeight))
        tableView.contentInset = UIEdgeInsets(top: -dummyTableTableHeaderViewHeight, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
    }
    
    // MARK: - Functions
    
    /// Goes through all notification cells to synchronize their isEnabled to represent the state of isNotificationEnabled
    func synchronizeAllIsEnabled() {
        // useNotificationsCell is always isEnabled true
        
        if let silentModeRow = settingsNotifsTVCReuseIdentifiers.firstIndex(of: SettingsNotifsSilentModeTVC.reuseIdentifier) {
            let silentModeCellIndexPath = IndexPath(row: silentModeRow, section: 0)
            if let silentModeCell = tableView(tableView, cellForRowAt: silentModeCellIndexPath) as? SettingsNotifsSilentModeTVC {
                silentModeCell.synchronizeIsEnabled()
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [silentModeCellIndexPath], with: .none)
            }
        }
        
        settingsNotifsCategoriesTableVC?.synchronizeAllIsEnabled()
        
        settingsNotifsAlarmsTableVC?.synchronizeAllIsEnabled()
    }
    
    /// Goes through all notification cells to synchronize their values to represent what is stored
    func synchronizeAllValues(animated: Bool) {
        synchronizeAllIsEnabled()
        
        if let useNotificationsRow = settingsNotifsTVCReuseIdentifiers.firstIndex(of: SettingsNotifsUseNotificationsTVC.reuseIdentifier) {
            let useNotificationsIndexPath = IndexPath(row: useNotificationsRow, section: 0)
            if let useNotificationsCell = tableView(tableView, cellForRowAt: useNotificationsIndexPath) as? SettingsNotifsUseNotificationsTVC {
                useNotificationsCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [useNotificationsIndexPath], with: .none)
            }
        }
        
        if let silentModeRow = settingsNotifsTVCReuseIdentifiers.firstIndex(of: SettingsNotifsSilentModeTVC.reuseIdentifier) {
            let silentModeCellIndexPath = IndexPath(row: silentModeRow, section: 0)
            if let silentModeCell = tableView(tableView, cellForRowAt: silentModeCellIndexPath) as? SettingsNotifsSilentModeTVC {
                silentModeCell.synchronizeValues(animated: animated)
                // we have to reload the cell specifically to be able to see the changes
                tableView.reloadRows(at: [silentModeCellIndexPath], with: .none)
            }
        }
        
        settingsNotifsCategoriesTableVC?.synchronizeAllValues(animated: animated)
        
        settingsNotifsAlarmsTableVC?.synchronizeAllValues(animated: animated)
    }
    
    /// The isNotificationAuthorized, isNotificationEnabled, and isLoudNotificationEnabled have been potentially updated. Additionally, SettingsNotifsTableVC could be be the last view opened. Therefore, we need to inform SettingsNotifsTableVC of these changes so that it can update its switches.
    static func didSynchronizeNotificationAuthorization() {
        SettingsNotifsTableVC.settingsNotifsTableVC?.synchronizeAllValues(animated: true)
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsNotifsTVCReuseIdentifiers.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SettingsNotifsTableHeaderV()
        
        headerView.setup(forTitle: "Notifications")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        SettingsNotifsTableHeaderV.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // We will be indexing SettingsNotifsCategoriesTVCs.allCases for the cell identifier, therefore make sure the cell is within a defined range
        guard indexPath.row < settingsNotifsTVCReuseIdentifiers.count else {
            return GeneralUITableViewCell()
        }
        
        let identifier = settingsNotifsTVCReuseIdentifiers[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if let cell = cell as? SettingsNotifsUseNotificationsTVC {
            cell.setup(forDelegate: self)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        // None of the rows should highlight. Either they have specific controls in them or open an external view controller
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let identifier = settingsNotifsTVCReuseIdentifiers[indexPath.row]
        
        switch identifier {
        case SettingsNotifsCategoriesTVC.reuseIdentifier:
            let vc = SettingsNotifsCategoriesTableVC()
            PresentationManager.enqueueViewController(vc)
        case SettingsNotifsAlarmsTVC.reuseIdentifier:
            let vc = SettingsNotifsAlarmsTableVC()
            PresentationManager.enqueueViewController(vc)
        default:
            break
        }
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
