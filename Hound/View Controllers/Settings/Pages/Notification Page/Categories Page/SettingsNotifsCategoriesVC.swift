import UIKit

final class SettingsNotifsCategoriesVC: HoundViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties

    private lazy var tableView = {
        let tableView = HoundTableView(style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        
        settingsNotifsCategoriesTVCReuseIdentifiers.forEach { identifier in
            switch identifier {
            case SettingsNotifsCategoriesAccountTVC.reuseIdentifier:
                tableView.register(SettingsNotifsCategoriesAccountTVC.self, forCellReuseIdentifier: identifier)
            case SettingsNotifsCategoriesFamilyTVC.reuseIdentifier:
                tableView.register(SettingsNotifsCategoriesFamilyTVC.self, forCellReuseIdentifier: identifier)
            case SettingsNotifsCategoriesLogTVC.reuseIdentifier:
                tableView.register(SettingsNotifsCategoriesLogTVC.self, forCellReuseIdentifier: identifier)
            case SettingsNotifsCategoriesReminderTVC.reuseIdentifier:
                tableView.register(SettingsNotifsCategoriesReminderTVC.self, forCellReuseIdentifier: identifier)
            default:
                fatalError("You must register all table view cells")
            }
        }
        
        return tableView
    }()
    
    private let settingsNotifsCategoriesTVCReuseIdentifiers = [
        SettingsNotifsCategoriesAccountTVC.reuseIdentifier,
        SettingsNotifsCategoriesFamilyTVC.reuseIdentifier,
        SettingsNotifsCategoriesLogTVC.reuseIdentifier,
        SettingsNotifsCategoriesReminderTVC.reuseIdentifier
    ]

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
    }

    // MARK: - Functions

    func synchronizeAllIsEnabled() {
        // NO-OP class SettingsNotifsCategoriesAccountTVC
        // NO-OP class SettingsNotifsCategoriesFamilyTVC

        if let logRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsCategoriesLogTVC.reuseIdentifier) {
            let logIndexPath = IndexPath(row: logRow, section: 0)
            tableView.reloadRows(at: [logIndexPath], with: .fade)
        }

        if let reminderRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsCategoriesReminderTVC.reuseIdentifier) {
            let reminderIndexPath = IndexPath(row: reminderRow, section: 0)
            tableView.reloadRows(at: [reminderIndexPath], with: .fade)
        }
    }

    func synchronizeAllValues(animated: Bool) {
        synchronizeAllIsEnabled()
        // NO-OP class SettingsNotifsCategoriesAccountTVC
        // NO-OP class SettingsNotifsCategoriesFamilyTVC

        if let logRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsCategoriesLogTVC.reuseIdentifier) {
            let logIndexPath = IndexPath(row: logRow, section: 0)
            tableView.reloadRows(at: [logIndexPath], with: .fade)
        }

        if let reminderRow = settingsNotifsCategoriesTVCReuseIdentifiers.firstIndex(of: SettingsNotifsCategoriesReminderTVC.reuseIdentifier) {
            let reminderIndexPath = IndexPath(row: reminderRow, section: 0)
            tableView.reloadRows(at: [reminderIndexPath], with: .fade)
        }
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsNotifsCategoriesTVCReuseIdentifiers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < settingsNotifsCategoriesTVCReuseIdentifiers.count else {
            return HoundTableViewCell()
        }
        let identifier = settingsNotifsCategoriesTVCReuseIdentifiers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = PageSheetHeaderFooterView()
        headerView.setup(forTitle: "Categories")
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
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

        // tableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
