//
//  LogsTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsTableViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
    func didSelectLog(forDogUUID: UUID, forLog: Log)
    func shouldUpdateNoLogsRecorded(forIsHidden: Bool)
    func shouldUpdateAlphaForButtons(forAlpha: Double)
    func shouldUpdateFilterLogsButton()
}

final class LogsTableViewController: GeneralUITableViewController {
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let referenceContentOffsetY = referenceContentOffsetY else {
            return
        }
        
        // Sometimes the default contentOffset.y isn't 0.0, in testing it was -47.0, so we want to adjust that value to 0.0
        let adjustedContentOffsetY = scrollView.contentOffset.y - referenceContentOffsetY
        // When scrollView.contentOffset.y reaches the value of alphaConstant, the UI element's alpha is set to 0 and is hidden.
        let alphaConstant: Double = 100.0
        let alpha: Double = max(1.0 - (adjustedContentOffsetY / alphaConstant), 0.0)
        delegate.shouldUpdateAlphaForButtons(forAlpha: alpha)
    }
    
    // MARK: - Properties
    
    /// Array of tuples [[(forDogUUID, log)]]. This array has all of the logs for all of the dogs grouped what unique day/month/year they occured on, first element is furthest in the future and last element is the oldest. Optionally filters by the dogUUID and logAction provides IMPORTANT to store this value so we don't recompute more than needed
    var logsForDogUUIDsGroupedByDate: [[(UUID, Log)]] = []
    
    private var storedLogsFilter: LogsFilter = LogsFilter(forDogManager: DogManager())
    var logsFilter: LogsFilter {
        get {
            storedLogsFilter
        }
        set {
            self.storedLogsFilter = newValue
            
            // If the view isn't currently visible, then we don't reload the data. We only reload the data once necessary, otherwise it's unnecessary processing to reload data that isn't in use. Without this change, for example, we could reloadTable() multiple times while a user is just modify reminders on the reminders page.
            guard self.viewIfLoaded?.window != nil else {
                tableViewDataSourceHasBeenUpdated = true
                return
            }
            
            reloadTable()
        }
    }
    
    /// We only want to refresh the tableViewDataSource when the viewController is visible. Otherwise, its a drain on resources to perform all of these calculations
    private var tableViewDataSourceHasBeenUpdated: Bool = false
    
    weak var delegate: LogsTableViewControllerDelegate!
    
    /// dummyTableTableHeaderViewHeight conflicts with our tableView. By adding it, we set our content inset to -dummyTableTableHeaderViewHeight. This change, when scrollViewDidScroll is invoked, makes it appear that we are scrolled dummyTableTableHeaderViewHeight down further than we are. Additionally, there is always some constant contentOffset, normally about -47.0, that is applied because of our tableView being constrainted to the superview and not safe area. Therefore, we have to track and correct for these.
    private(set) var referenceContentOffsetY: Double?
    
    // MARK: Page Loader
    
    /// How much logsDisplayedLimit is incremented by each time the user reaches the end and more logs need to be loaded
    private static var logsDisplayedLimitIncrementation = 100
    /// Number of logs that can be simultaneously displayed. This starts as logsDisplayedLimitIncrementation x 2, and whenever the currently displayed logs come within logsDisplayedLimitIncrementation of logsDisplayedLimit, then increments logsDisplayedLimit with an additional logsDisplayedLimitIncrementation
    static var logsDisplayedLimit: Int = logsDisplayedLimitIncrementation * 2
    
    // MARK: - Dog Manager
    
    private(set) var dogManager: DogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        logsFilter.apply(forDogManager: forDogManager)
        
        if (sender.localized is LogsTableViewController) == true {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        
        reloadTable()
        
        delegate.shouldUpdateFilterLogsButton()
        delegate.shouldUpdateNoLogsRecorded(forIsHidden: !logsForDogUUIDsGroupedByDate.isEmpty)
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = true
        // allow for refreshing of the information from the server
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableViewDataSourceHasBeenUpdated = false
        
        reloadTable()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        let dummyTableTableHeaderViewHeight = 100.0
        // Adding a tableHeaderView prevents section headers from sticking and floating at the top of the page when we scroll up. This is because we are basically adding a large blank space to the top of the screen, allowing a space for the header to scroll into
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyTableTableHeaderViewHeight))
        tableView.contentInset = UIEdgeInsets(top: -dummyTableTableHeaderViewHeight, left: 0, bottom: 0, right: 0)
        
        if referenceContentOffsetY == nil {
            referenceContentOffsetY = tableView.contentOffset.y
        }
    }
    
    // MARK: - Functions
    
    /// Makes a query to the server to retrieve new information then refreshed the tableView
    @objc private func refreshTableData() {
        PresentationManager.beginFetchingInformationIndictator()
        DogsRequest.get(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogManager: dogManager) { newDogManager, responseStatus, _ in
            PresentationManager.endFetchingInformationIndictator {
                // end refresh first otherwise there will be a weird visual issue
                self.tableView.refreshControl?.endRefreshing()
                guard responseStatus != .failureResponse, let newDogManager = newDogManager else {
                    return
                }
                
                if responseStatus == .successResponse {
                    PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.successRefreshLogsTitle, forSubtitle: VisualConstant.BannerTextConstant.successRefreshLogsSubtitle, forStyle: .success)
                }
                else {
                    if OfflineModeManager.shared.hasDisplayedOfflineModeBanner == true {
                        // If OfflineModeManager has displayed its banner that indicates its turning on, then we are safe to display this banner. Otherwise, we would run the risk of both of these banners displaying if its the first time enterin offline mode.
                        PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.infoRefreshOnHoldTitle, forSubtitle: VisualConstant.BannerTextConstant.infoRefreshOnHoldSubtitle, forStyle: .info)
                    }
                }
                
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
            }
        }
    }
    
    /// Updates dogManagerDependents then reloads table
    private func reloadTable() {
        // important to store this value so we don't recompute more than needed
        logsForDogUUIDsGroupedByDate = dogManager.logsForDogUUIDsGroupedByDate(forFilter: logsFilter)
        tableView.isUserInteractionEnabled = logsForDogUUIDsGroupedByDate.isEmpty == false
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return logsForDogUUIDsGroupedByDate.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if we want to display rows, there must be logs to display, and if there is logs to display then there must be a page loader section
        guard logsForDogUUIDsGroupedByDate.isEmpty == false else {
            return 0
        }
        
        return logsForDogUUIDsGroupedByDate[section].count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = LogsTableHeaderView()
        
        let date = logsForDogUUIDsGroupedByDate[section].first?.1.logStartDate ?? Date()
        headerView.setup(fromDate: date)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return LogsTableHeaderView.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard logsForDogUUIDsGroupedByDate.isEmpty == false else {
            // there are either no rows to display, or the current section is the loader section which means we don't display any custom cells
            return UITableViewCell()
        }
        
        let (dogUUID, log) = logsForDogUUIDsGroupedByDate[indexPath.section][indexPath.row]
        
        guard let dog = dogManager.findDog(forDogUUID: dogUUID) else {
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LogsTableViewCell", for: indexPath) as? LogsTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setup(forParentDogName: dog.dogName, forLog: log)
        
        cell.containerView.roundCorners(setCorners: .none)
        
        // This cell is a top cell
        if indexPath.row == 0 {
            cell.containerView.roundCorners(addCorners: .top)
        }
        // This cell is a bottom cell (and possibly a top cell as well)
        if indexPath.row == logsForDogUUIDsGroupedByDate[indexPath.section].count - 1 {
            cell.containerView.roundCorners(addCorners: .bottom)
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let (forDogUUID, forLog) = logsForDogUUIDsGroupedByDate[indexPath.section][indexPath.row]
        
        LogsRequest.delete(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forLogUUID: forLog.logUUID) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                return
            }
            
            self.dogManager.findDog(forDogUUID: forDogUUID)?.dogLogs.removeLog(forLogUUID: forLog.logUUID)
            self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (forDogUUID, forLog) = logsForDogUUIDsGroupedByDate[indexPath.section][indexPath.row]
        
        PresentationManager.beginFetchingInformationIndictator()
        LogsRequest.get(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: forDogUUID, forLog: forLog) { log, responseStatus, _ in
            PresentationManager.endFetchingInformationIndictator {
                self.tableView.deselectRow(at: indexPath, animated: true)
                guard responseStatus != .failureResponse else {
                    return
                }
                
                guard let log = log else {
                    // If the response was successful but no log was returned, that means the log was deleted. Therefore, update the dogManager to indicate as such.
                    self.dogManager.findDog(forDogUUID: forDogUUID)?.dogLogs.removeLog(forLogUUID: forLog.logUUID)
                    self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    return
                }
                
                self.delegate.didSelectLog(forDogUUID: forDogUUID, forLog: log)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // we are aiming to load more data if the user has scrolled to the bottom. this in indicated by the page loader section being shown
        var possibleLogsDisplayed = 0
        var currentLogsDisplayed = 0
        
        for (index, array) in logsForDogUUIDsGroupedByDate.enumerated() {
            possibleLogsDisplayed += array.count
            
            if index <= indexPath.section {
                currentLogsDisplayed += array.count
            }
        }
        
        // If the number of possible logs to be displayed is at the logsDisplayedLimit, that means we have enough logs to fill up the limit (and there are more to be displayed which are currently hidden. Additionally, given this, if currentLogsDisplayed is within a certain (close) range of possibleLogsDisplayed, then the user is scrolling to the end of what we are displaying, and we should display more
        guard (possibleLogsDisplayed == LogsTableViewController.logsDisplayedLimit) && currentLogsDisplayed >= (possibleLogsDisplayed - LogsTableViewController.logsDisplayedLimitIncrementation) else {
            return
        }
        
        LogsTableViewController.logsDisplayedLimit += LogsTableViewController.logsDisplayedLimitIncrementation
        reloadTable()
    }
    
}
