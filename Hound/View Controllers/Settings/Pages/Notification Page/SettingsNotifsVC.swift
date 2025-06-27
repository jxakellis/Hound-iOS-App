import UIKit

// TODO VERIFY UI
final class SettingsNotifsVC: GeneralUIViewController, UITableViewDelegate, UITableViewDataSource, SettingsNotifsUseNotificationsTVCDelegate {

    // MARK: - SettingsNotifsUseNotificationsTVCDelegate

    func didToggleIsNotificationEnabled() {
        synchronizeAllIsEnabled()
    }

    // MARK: - Properties

    private static var settingsNotifsVC: SettingsNotifsVC?

    private var settingsNotifsCategoriesVC: SettingsNotifsCategoriesVC?
    
    private var settingsNotifsAlarmsVC: SettingsNotifsAlarmsVC?
    
    private lazy var tableView = {
        let tableView = GeneralUITableView()
        tableView.enableDummyHeaderView = true
        tableView.delegate = self
        tableView.dataSource = self
        
        settingsNotifsTVCReuseIdentifiers.forEach { identifier in
            switch identifier {
            case SettingsNotifsUseNotificationsTVC.reuseIdentifier:
                tableView.register(SettingsNotifsUseNotificationsTVC.self, forCellReuseIdentifier: SettingsNotifsUseNotificationsTVC.reuseIdentifier)
            case SettingsNotifsSilentModeTVC.reuseIdentifier:
                tableView.register(SettingsNotifsSilentModeTVC.self, forCellReuseIdentifier: SettingsNotifsSilentModeTVC.reuseIdentifier)
            case SettingsNotifsCategoriesTVC.reuseIdentifier:
                tableView.register(SettingsNotifsCategoriesTVC.self, forCellReuseIdentifier: SettingsNotifsCategoriesTVC.reuseIdentifier)
            case SettingsNotifsAlarmsTVC.reuseIdentifier:
                tableView.register(SettingsNotifsAlarmsTVC.self, forCellReuseIdentifier: SettingsNotifsAlarmsTVC.reuseIdentifier)
            default:
                fatalError("You must register all table view cells")
            }
        }
        
        return tableView
    }()

    private let settingsNotifsTVCReuseIdentifiers = [
        SettingsNotifsUseNotificationsTVC.reuseIdentifier,
        SettingsNotifsSilentModeTVC.reuseIdentifier,
        SettingsNotifsCategoriesTVC.reuseIdentifier,
        SettingsNotifsAlarmsTVC.reuseIdentifier
    ]

    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        SettingsNotifsVC.settingsNotifsVC = self
    }

    // MARK: - Functions

    func synchronizeAllIsEnabled() {
        if let silentModeRow = settingsNotifsTVCReuseIdentifiers.firstIndex(of: SettingsNotifsSilentModeTVC.reuseIdentifier) {
            let silentModeCellIndexPath = IndexPath(row: silentModeRow, section: 0)
            if let silentModeCell = tableView.cellForRow(at: silentModeCellIndexPath) as? SettingsNotifsSilentModeTVC {
                silentModeCell.synchronizeIsEnabled()
                tableView.reloadRows(at: [silentModeCellIndexPath], with: .none)
            }
        }
        settingsNotifsCategoriesVC?.synchronizeAllIsEnabled()
        settingsNotifsAlarmsVC?.synchronizeAllIsEnabled()
    }

    func synchronizeAllValues(animated: Bool) {
        synchronizeAllIsEnabled()
        if let useNotificationsRow = settingsNotifsTVCReuseIdentifiers.firstIndex(of: SettingsNotifsUseNotificationsTVC.reuseIdentifier) {
            let useNotificationsIndexPath = IndexPath(row: useNotificationsRow, section: 0)
            if let useNotificationsCell = tableView.cellForRow(at: useNotificationsIndexPath) as? SettingsNotifsUseNotificationsTVC {
                useNotificationsCell.synchronizeValues(animated: animated)
                tableView.reloadRows(at: [useNotificationsIndexPath], with: .none)
            }
        }
        if let silentModeRow = settingsNotifsTVCReuseIdentifiers.firstIndex(of: SettingsNotifsSilentModeTVC.reuseIdentifier) {
            let silentModeCellIndexPath = IndexPath(row: silentModeRow, section: 0)
            if let silentModeCell = tableView.cellForRow(at: silentModeCellIndexPath) as? SettingsNotifsSilentModeTVC {
                silentModeCell.synchronizeValues(animated: animated)
                tableView.reloadRows(at: [silentModeCellIndexPath], with: .none)
            }
        }
        settingsNotifsCategoriesVC?.synchronizeAllValues(animated: animated)
        settingsNotifsAlarmsVC?.synchronizeAllValues(animated: animated)
    }

    static func didSynchronizeNotificationAuthorization() {
        SettingsNotifsVC.settingsNotifsVC?.synchronizeAllValues(animated: true)
    }

    // MARK: - Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsNotifsTVCReuseIdentifiers.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = PageSheetHeaderFooterView()
        headerView.setup(forTitle: "Notifications")
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let identifier = settingsNotifsTVCReuseIdentifiers[indexPath.row]
        switch identifier {
        case SettingsNotifsCategoriesTVC.reuseIdentifier:
            let vc = SettingsNotifsCategoriesVC()
            PresentationManager.enqueueViewController(vc)
        case SettingsNotifsAlarmsTVC.reuseIdentifier:
            let vc = SettingsNotifsAlarmsVC()
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
