//
//  LogsTableVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsTableVCDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, dogManager: DogManager)
    func didSelectLog(dogUUID: UUID, log: Log)
    func shouldUpdateNoLogsRecorded(isHidden: Bool)
    func shouldUpdateAlphaForButtons(alpha: Double)
    func updateFilterLogsButton()
}

// UI VERIFIED 6/25/25
final class LogsTableVC: HoundTableViewController {
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let referenceContentOffsetY = referenceContentOffsetY else { return }
        
        // Sometimes the default contentOffset.y isn't 0.0; adjust it to 0.0
        let adjustedContentOffsetY = scrollView.contentOffset.y - referenceContentOffsetY
        // When contentOffset.y reaches alphaConstant, UI element's alpha becomes 0
        let alphaConstant: Double = 100.0
        let alpha: Double = max(1.0 - (adjustedContentOffsetY / alphaConstant), 0.0)
        delegate?.shouldUpdateAlphaForButtons(alpha: alpha)
    }
    
    // MARK: - Properties
    
    /// Array of tuples [[(dogUUID, log)]].
    /// Logs are grouped by date; first element is future, last is oldest.
    private(set) var logsForDogUUIDsGroupedByDate: [[(UUID, Log)]] = [] {
        didSet {
            delegate?.shouldUpdateNoLogsRecorded(isHidden: !logsForDogUUIDsGroupedByDate.isEmpty)
        }
    }
    
    private var storedLogsSort: LogsSort = LogsSort()
    var logsSort: LogsSort {
        get {
            storedLogsSort
        }
        set {
            self.storedLogsSort = newValue
            
            // Only reload data if view is visible; otherwise mark for later update
            guard self.viewIfLoaded?.window != nil else {
                tableViewDataSourceHasBeenUpdated = true
                return
            }
            
            reloadTable()
        }
    }
    
    private var storedLogsFilter: LogsFilter = LogsFilter(dogManager: DogManager())
    var logsFilter: LogsFilter {
        get {
            storedLogsFilter
        }
        set {
            self.storedLogsFilter = newValue
            
            // Only reload data if view is visible; otherwise mark for later update
            guard self.viewIfLoaded?.window != nil else {
                tableViewDataSourceHasBeenUpdated = true
                return
            }
            
            reloadTable()
        }
    }
    
    /// Track if we need to refresh data when view appears
    private var tableViewDataSourceHasBeenUpdated: Bool = false

    /// Allows temporarily disabling table reloads when setDogManager is called.
    private var allowReloadTable: Bool = true
    
    private weak var delegate: LogsTableVCDelegate?
    
    // MARK: Page Loader
    
    /// How many logs to load each time user scrolls to bottom
    private static var logsDisplayedLimitIncrementation = 100
    /// Number of logs currently displayed; initial value is twice the incrementation
    static var logsDisplayedLimit: Int = logsDisplayedLimitIncrementation * 2
    
    // MARK: - Dog Manager
    
    private(set) var dogManager: DogManager = DogManager()
    
    /// Update dogManager and refresh UI accordingly
    func setDogManager(sender: Sender, dogManager: DogManager) {
        self.dogManager = dogManager
        logsFilter.apply(dogManager: dogManager)
        
        if (sender.localized is LogsTableVC) == true {
            delegate?.didUpdateDogManager(sender: Sender(origin: sender, localized: self), dogManager: dogManager)
        }
        
        reloadTable()
        
        delegate?.updateFilterLogsButton()
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.enableDummyHeaderView = true
        self.tableView.register(LogTVC.self, forCellReuseIdentifier: LogTVC.reuseIdentifier)
        self.tableView.contentInset.top = Constant.Constraint.Spacing.absoluteVertInset
        self.tableView.contentInset.bottom = Constant.Constraint.Spacing.absoluteVertInset
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If data was updated offscreen, reload table now
        if tableViewDataSourceHasBeenUpdated {
            reloadTable()
            tableViewDataSourceHasBeenUpdated = false
        }
        else {
            reloadTable()
        }
    }
    
    // MARK: - Setup
    
    func setup(delegate: LogsTableVCDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Functions
    
    /// Fetch new logs from server, then reload table
    @objc private func refreshTableData() {
        PresentationManager.beginFetchingInformationIndicator()
        DogsRequest.get(
            errorAlert: .automaticallyAlertOnlyForFailure,
            dogManager: dogManager
        ) { newDogManager, responseStatus, _ in
            PresentationManager.endFetchingInformationIndicator {
                // End refresh animation first to avoid visual glitch
                self.tableView.refreshControl?.endRefreshing()
                
                guard responseStatus != .failureResponse, let newDogManager = newDogManager else {
                    return
                }
                
                if responseStatus == .successResponse {
                    PresentationManager.enqueueBanner(
                        title: Constant.Visual.BannerText.successRefreshLogsTitle,
                        subtitle: Constant.Visual.BannerText.successRefreshLogsSubtitle,
                        style: .success
                    )
                }
                else {
                    if OfflineModeManager.shared.hasDisplayedOfflineModeBanner == true {
                        // Only show if offline banner already shown
                        PresentationManager.enqueueBanner(
                            title: Constant.Visual.BannerText.infoRefreshOnHoldTitle,
                            subtitle: Constant.Visual.BannerText.infoRefreshOnHoldSubtitle,
                            style: .info
                        )
                    }
                }
                
                self.setDogManager(
                    sender: Sender(origin: self, localized: self),
                    dogManager: newDogManager
                )
            }
        }
    }
    
    /// Compute logsForDogUUIDsGroupedByDate and reload table view
    private func reloadTable() {
        // Avoid recomputation if no logs
        logsForDogUUIDsGroupedByDate = dogManager.logsForDogUUIDsGroupedByDate(filter: logsFilter, sort: logsSort)
        tableView.isUserInteractionEnabled = !logsForDogUUIDsGroupedByDate.isEmpty
        guard allowReloadTable else { return }
        tableView.reloadData()
    }
    
    func scrollToTop(animated: Bool) {
        guard let referenceContentOffsetY = referenceContentOffsetY else { return }
        tableView.setContentOffset(CGPoint(x: 0, y: referenceContentOffsetY), animated: animated)
    }
    
    override func didUpdateUserTimeZone() {
        reloadTable()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return logsForDogUUIDsGroupedByDate.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // No logs => no rows
        guard !logsForDogUUIDsGroupedByDate.isEmpty else {
            return 0
        }
        
        return logsForDogUUIDsGroupedByDate[section].count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HoundTableHeaderFooterView()
        
        let date = logsForDogUUIDsGroupedByDate[section].first?.1.logStartDate ?? Date()
        let currentYear = Calendar.user.component(.year, from: Date())
        let dateYear = Calendar.user.component(.year, from: date)
        
        // today
        if Calendar.user.isDateInToday(date) {
            headerView.setTitle("Today")
        }
        // yesterday
        else if Calendar.user.isDateInYesterday(date) {
            headerView.setTitle("Yesterday")
        }
        else if Calendar.user.isDateInTomorrow(date) {
            headerView.setTitle("Tomorrow")
        }
        else {
            // Wednesday, January 25 or Wednesday, January 25 2023
            let template = dateYear == currentYear ? "EEEEMMMMd" : "EEEEMMMMdyyyy"
            headerView.setTitle(date.houndFormatted(.template(template), displayTimeZone: UserConfiguration.timeZone))
        }
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !logsForDogUUIDsGroupedByDate.isEmpty else {
            return HoundTableViewCell()
        }
        
        let (dogUUID, log) = logsForDogUUIDsGroupedByDate[indexPath.section][indexPath.row]
        
        guard let dog = dogManager.findDog(dogUUID: dogUUID) else {
            return HoundTableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LogTVC.reuseIdentifier,
            for: indexPath
        ) as? LogTVC else {
            return HoundTableViewCell()
        }
        
        cell.setup(parentDogName: dog.dogName, log: log)
        
        // Reset rounding before applying new corners
        cell.containerView.roundCorners(setCorners: .none)
        
        // Top cell: round top corners
        if indexPath.row == 0 {
            cell.containerView.roundCorners(addCorners: .top)
        }
        // Bottom cell: round bottom corners
        if indexPath.row == logsForDogUUIDsGroupedByDate[indexPath.section].count - 1 {
            cell.containerView.roundCorners(addCorners: .bottom)
        }
        
        return cell
    }
    
    // Allow swipe-to-delete
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Handle deletion of a log
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        
        let (dogUUID, log) = logsForDogUUIDsGroupedByDate[indexPath.section][indexPath.row]
        
        LogsRequest.delete(
            errorAlert: .automaticallyAlertOnlyForFailure,
            dogUUID: dogUUID,
            logUUID: log.logUUID
        ) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                return
            }
            
            let previousLogs = self.logsForDogUUIDsGroupedByDate

            self.dogManager.findDog(dogUUID: dogUUID)?
                .dogLogs.removeLog(logUUID: log.logUUID)

            self.allowReloadTable = false
            self.setDogManager(
                sender: Sender(origin: self, localized: self),
                dogManager: self.dogManager
            )
            self.allowReloadTable = true

            let newLogs = self.logsForDogUUIDsGroupedByDate
            self.tableView.isUserInteractionEnabled = !newLogs.isEmpty
            
            if previousLogs[indexPath.section].count > 1 && indexPath.row == previousLogs[indexPath.section].count - 1 {
                // there is an above log and it needs its corners counred since its the new bottom
                let aboveLogCell = self.tableView.cellForRow(at: IndexPath(row: indexPath.row - 1, section: indexPath.section)) as? LogTVC
                UIView.animate(withDuration: Constant.Visual.Animation.showOrHideSingleElement) {
                    aboveLogCell?.containerView.roundCorners(addCorners: .bottom)
                }
            }

            self.tableView.beginUpdates()
            if previousLogs[indexPath.section].count == 1 {
                self.tableView.deleteSections([indexPath.section], with: .automatic)
            }
            else {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            self.tableView.endUpdates()

            UIView.animate(withDuration: Constant.Visual.Animation.moveMultipleElements) {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (dogUUID, log) = logsForDogUUIDsGroupedByDate[indexPath.section][indexPath.row]
        
        PresentationManager.beginFetchingInformationIndicator()
        LogsRequest.get(
            errorAlert: .automaticallyAlertOnlyForFailure,
            dogUUID: dogUUID,
            log: log
        ) { responseLog, responseStatus, _ in
            PresentationManager.endFetchingInformationIndicator {
                self.tableView.deselectRow(at: indexPath, animated: true)
                
                guard responseStatus != .failureResponse else {
                    return
                }
                
                guard let responseLog = responseLog else {
                    // Log was deleted on server; update local manager
                    self.dogManager.findDog(dogUUID: dogUUID)?.dogLogs.removeLog(logUUID: log.logUUID)
                    self.setDogManager(
                        sender: Sender(origin: self, localized: self),
                        dogManager: self.dogManager
                    )
                    return
                }
                
                self.delegate?.didSelectLog(dogUUID: dogUUID, log: responseLog)
            }
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        // Check if user has scrolled near bottom to load more logs
        var possibleLogsDisplayed = 0
        var currentLogsDisplayed = 0
        
        for (index, array) in logsForDogUUIDsGroupedByDate.enumerated() {
            possibleLogsDisplayed += array.count
            if index <= indexPath.section {
                currentLogsDisplayed += array.count
            }
        }
        
        // If at limit and near bottom, increase limit and reload
        guard (possibleLogsDisplayed == LogsTableVC.logsDisplayedLimit),
              currentLogsDisplayed >= (possibleLogsDisplayed - LogsTableVC.logsDisplayedLimitIncrementation)
        else { return }
        
        LogsTableVC.logsDisplayedLimit += LogsTableVC.logsDisplayedLimitIncrementation
        reloadTable()
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        tableView.backgroundColor = UIColor.secondarySystemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
    }
}
