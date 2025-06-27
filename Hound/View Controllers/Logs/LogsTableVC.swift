//
//  LogsTableVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsTableVCDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
    func didSelectLog(forDogUUID: UUID, forLog: Log)
    func shouldUpdateNoLogsRecorded(forIsHidden: Bool)
    func shouldUpdateAlphaForButtons(forAlpha: Double)
    func shouldUpdateFilterLogsButton()
}

// UI VERIFIED 6/25/25
final class LogsTableVC: GeneralUITableViewController {
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard let referenceContentOffsetY = referenceContentOffsetY else {
//            return
//        }
        
        // Sometimes the default contentOffset.y isn't 0.0; adjust it to 0.0
        let adjustedContentOffsetY = scrollView.contentOffset.y - tableView.contentOffset.y
        // When contentOffset.y reaches alphaConstant, UI element's alpha becomes 0
        let alphaConstant: Double = 100.0
        let alpha: Double = max(1.0 - (adjustedContentOffsetY / alphaConstant), 0.0)
        delegate?.shouldUpdateAlphaForButtons(forAlpha: alpha)
    }
    
    // MARK: - Properties
    
    /// Array of tuples [[(forDogUUID, log)]].
    /// Logs are grouped by date; first element is future, last is oldest.
    private(set) var logsForDogUUIDsGroupedByDate: [[(UUID, Log)]] = []
    
    private var storedLogsFilter: LogsFilter = LogsFilter(forDogManager: DogManager())
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
    
    private weak var delegate: LogsTableVCDelegate?
    
    // MARK: Page Loader
    
    /// How many logs to load each time user scrolls to bottom
    private static var logsDisplayedLimitIncrementation = 100
    /// Number of logs currently displayed; initial value is twice the incrementation
    static var logsDisplayedLimit: Int = logsDisplayedLimitIncrementation * 2
    
    // MARK: - Dog Manager
    
    private(set) var dogManager: DogManager = DogManager()
    
    /// Update dogManager and refresh UI accordingly
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        logsFilter.apply(forDogManager: forDogManager)
        
        if (sender.localized is LogsTableVC) == true {
            delegate?.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        
        reloadTable()
        
        delegate?.shouldUpdateFilterLogsButton()
        delegate?.shouldUpdateNoLogsRecorded(forIsHidden: !logsForDogUUIDsGroupedByDate.isEmpty)
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.enableDummyHeaderView = true
        self.tableView.register(LogsTVC.self, forCellReuseIdentifier: LogsTVC.reuseIdentifier)
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
    
    func setup(forDelegate: LogsTableVCDelegate) {
        self.delegate = forDelegate
    }
    
    // MARK: - Functions
    
    /// Fetch new logs from server, then reload table
    @objc private func refreshTableData() {
        PresentationManager.beginFetchingInformationIndicator()
        DogsRequest.get(
            forErrorAlert: .automaticallyAlertOnlyForFailure,
            forDogManager: dogManager
        ) { newDogManager, responseStatus, _ in
            PresentationManager.endFetchingInformationIndicator {
                // End refresh animation first to avoid visual glitch
                self.tableView.refreshControl?.endRefreshing()
                
                guard responseStatus != .failureResponse, let newDogManager = newDogManager else {
                    return
                }
                
                if responseStatus == .successResponse {
                    PresentationManager.enqueueBanner(
                        forTitle: VisualConstant.BannerTextConstant.successRefreshLogsTitle,
                        forSubtitle: VisualConstant.BannerTextConstant.successRefreshLogsSubtitle,
                        forStyle: .success
                    )
                }
                else {
                    if OfflineModeManager.shared.hasDisplayedOfflineModeBanner == true {
                        // Only show if offline banner already shown
                        PresentationManager.enqueueBanner(
                            forTitle: VisualConstant.BannerTextConstant.infoRefreshOnHoldTitle,
                            forSubtitle: VisualConstant.BannerTextConstant.infoRefreshOnHoldSubtitle,
                            forStyle: .info
                        )
                    }
                }
                
                self.setDogManager(
                    sender: Sender(origin: self, localized: self),
                    forDogManager: newDogManager
                )
            }
        }
    }
    
    /// Compute logsForDogUUIDsGroupedByDate and reload table view
    private func reloadTable() {
        // Avoid recomputation if no logs
        logsForDogUUIDsGroupedByDate = dogManager.logsForDogUUIDsGroupedByDate(forFilter: logsFilter)
        tableView.isUserInteractionEnabled = !logsForDogUUIDsGroupedByDate.isEmpty
        tableView.reloadData()
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
        let headerView = GeneralHeaderView()
        
        let date = logsForDogUUIDsGroupedByDate[section].first?.1.logStartDate ?? Date()
        let currentYear = Calendar.current.component(.year, from: Date())
        let dateYear = Calendar.current.component(.year, from: date)
        
        // today
        if Calendar.current.isDateInToday(date) {
            headerView.setTitle("Today")
        }
        // yesterday
        else if Calendar.current.isDateInYesterday(date) {
            headerView.setTitle("Yesterday")
        }
        else if Calendar.current.isDateInTomorrow(date) {
            headerView.setTitle("Tomorrow")
        }
        else {
            let dateFormatter = DateFormatter()
            // Wednesday, January 25 or Wednesday, January 25 2023
            dateFormatter.setLocalizedDateFormatFromTemplate( dateYear == currentYear ? "EEEEMMMMd" : "EEEEMMMMdyyyy")
            
            headerView.setTitle(dateFormatter.string(from: date))
        }
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !logsForDogUUIDsGroupedByDate.isEmpty else {
            return GeneralUITableViewCell()
        }
        
        let (dogUUID, log) = logsForDogUUIDsGroupedByDate[indexPath.section][indexPath.row]
        
        guard let dog = dogManager.findDog(forDogUUID: dogUUID) else {
            return GeneralUITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LogsTVC.reuseIdentifier,
            for: indexPath
        ) as? LogsTVC else {
            return GeneralUITableViewCell()
        }
        
        cell.setup(forParentDogName: dog.dogName, forLog: log)
        
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
        guard editingStyle == .delete else {
            return
        }
        
        let (forDogUUID, forLog) = logsForDogUUIDsGroupedByDate[indexPath.section][indexPath.row]
        
        LogsRequest.delete(
            forErrorAlert: .automaticallyAlertOnlyForFailure,
            forDogUUID: forDogUUID,
            forLogUUID: forLog.logUUID
        ) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                return
            }
            
            self.dogManager.findDog(forDogUUID: forDogUUID)?
                .dogLogs.removeLog(forLogUUID: forLog.logUUID)
            self.setDogManager(
                sender: Sender(origin: self, localized: self),
                forDogManager: self.dogManager
            )
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (forDogUUID, forLog) = logsForDogUUIDsGroupedByDate[indexPath.section][indexPath.row]
        
        PresentationManager.beginFetchingInformationIndicator()
        LogsRequest.get(
            forErrorAlert: .automaticallyAlertOnlyForFailure,
            forDogUUID: forDogUUID,
            forLog: forLog
        ) { log, responseStatus, _ in
            PresentationManager.endFetchingInformationIndicator {
                self.tableView.deselectRow(at: indexPath, animated: true)
                
                guard responseStatus != .failureResponse else {
                    return
                }
                
                guard let log = log else {
                    // Log was deleted on server; update local manager
                    self.dogManager.findDog(forDogUUID: forDogUUID)?
                        .dogLogs.removeLog(forLogUUID: forLog.logUUID)
                    self.setDogManager(
                        sender: Sender(origin: self, localized: self),
                        forDogManager: self.dogManager
                    )
                    return
                }
                
                self.delegate?.didSelectLog(forDogUUID: forDogUUID, forLog: log)
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
        else {
            return
        }
        
        LogsTableVC.logsDisplayedLimit += LogsTableVC.logsDisplayedLimitIncrementation
        reloadTable()
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        tableView.backgroundColor = .secondarySystemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
    }
}
