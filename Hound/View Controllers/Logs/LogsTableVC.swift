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
    func didSelectLog(forDogId: Int, forLog: Log)
    func shouldUpdateNoLogsRecorded(forIsHidden: Bool)
    func didUpdateAlphaForButtons(forAlpha: Double)
}

final class LogsTableViewController: UITableViewController {
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Sometimes the default contentOffset.y isn't 0.0, in testing it was -47.0, so we want to adjust that value to 0.0
        let adjustedContentOffsetY = scrollView.contentOffset.y - (referenceContentOffsetAndInsetY ?? 0.0)
        // When scrollView.contentOffset.y reaches the value of alphaConstant, the UI element's alpha is set to 0 and is hidden.
        let alphaConstant: Double = 100.0
        let alpha: Double = max(1.0 - (adjustedContentOffsetY / alphaConstant), 0.0)
        
        delegate.didUpdateAlphaForButtons(forAlpha: alpha)
    }
    
    // MARK: - Properties
    
    /// Array of tuples [[(forDogId, log)]]. This array has all of the logs for all of the dogs grouped what unique day/month/year they occured on, first element is furthest in the future and last element is the oldest. Optionally filters by the dogId and logAction provides IMPORTANT to store this value so we don't recompute more than needed
    var logsForDogIdsGroupedByDate: [[(Int, Log)]] = []
    
    private var storedLogsFilter: [Int: [LogAction]] = [:]
    // Dictionary Literal of Dog IDs and their corresponding log actions. This indicates which dog(s) to filter by and what log actions of theirs to also filter by. [:] indicates no filter and all items are shown
    var logsFilter: [Int: [LogAction]] {
        get {
            return storedLogsFilter
        }
        set (newLogsFilter) {
            self.storedLogsFilter = newLogsFilter
            
            // If the view isn't currently visible, then we don't reload the data. We only reload the data once necessary, otherwise it's unnecessary processing to reload data that isn't in use. Without this change, for example, we could reloadTable() multiple times while a user is just modify reminders on the reminders page.
            guard self.viewIfLoaded?.window != nil else {
                tableViewDataSourceHasBeenUpdated = true
                return
            }
            
            reloadTable()
        }
    }
    
    /// used for determining if logs interface scale was changed and if the table view needs reloaded
    private var storedLogsInterfaceScale: LogsInterfaceScale = UserConfiguration.logsInterfaceScale
    
    /// We only want to refresh the tableViewDataSource when the viewController is visible. Otherwise, its a drain on resources to perform all of these calculations
    private var tableViewDataSourceHasBeenUpdated: Bool = false
    
    weak var delegate: LogsTableViewControllerDelegate!
    
    /// dummyTableHeaderViewHeight conflicts with our tableView. By adding it, we set our content inset to -dummyTableHeaderViewHeight, which then makes us think we are scrolled to a different point on the table. We have to track and correct for this adjustment. However, if we are externally changing contentOffset and not concerned with how far down we have scrolled, we can ignore contentInset and only worry about contentOffsert (no contentInset)
    private var referenceContentOffsetAndInsetY: Double?
    /// dummyTableHeaderViewHeight conflicts with our tableView. By adding it, we set our content inset to -dummyTableHeaderViewHeight, which then makes us think we are scrolled to a different point on the table. We have to track and correct for this adjustment. However, if we are externally changing contentOffset and not concerned with how far down we have scrolled, we can ignore contentInset and only worry about contentOffsert (no contentInset)
    private(set) var referenceContentOffsetY: Double?
    
    // MARK: Page Loader
    
    /// Number of logs that can be simultaneously displayed
    static var logsDisplayedLimit: Int = 250
    
    /// The section index in the table view designated for the page loader.
    var pageLoaderSectionIndex: Int? {
        // logsForDogIdsGroupedByDate.count == 2
        // section 0: first for logsForDogIdsGroupedByDate
        // section 1: second for logsForDogIdsGroupedByDate
        // section 2: page loader
        return logsForDogIdsGroupedByDate.isEmpty ? nil : logsForDogIdsGroupedByDate.count
    }
    
    // MARK: - Dog Manager
    
    private(set) var dogManager: DogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        reloadTable()
        
        if (sender.localized is LogsTableViewController) == true {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        
        delegate.shouldUpdateNoLogsRecorded(forIsHidden: !logsForDogIdsGroupedByDate.isEmpty)
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = true
        self.tableView.separatorStyle = .none
        // allow for refreshing of the information from the server
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableViewDataSourceHasBeenUpdated = false
        storedLogsInterfaceScale = UserConfiguration.logsInterfaceScale
        
        reloadTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let dummyTableHeaderViewHeight = 100.0
        // Adding a tableHeaderView prevents section headers from sticking and floating at the top of the page when we scroll up. This is because we are basically adding a large blank space to the top of the screen, allowing a space for the header to scroll into
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyTableHeaderViewHeight))
        tableView.contentInset = UIEdgeInsets(top: -dummyTableHeaderViewHeight, left: 0, bottom: 0, right: 0)
        
        if referenceContentOffsetAndInsetY == nil {
            referenceContentOffsetAndInsetY = tableView.contentOffset.y - tableView.contentInset.top
            referenceContentOffsetY = tableView.contentOffset.y
            // scrollViewDidScroll can be called at a point in which defaultContentOffsetY is ni, providing faulty alpha. This corrects for that
            delegate.didUpdateAlphaForButtons(forAlpha: 1.0)
        }
    }
    
    // MARK: - Functions
    
    /// Makes a query to the server to retrieve new information then refreshed the tableView
    @objc private func refreshTableData() {
        DogsRequest.get(invokeErrorManager: true, dogManager: dogManager) { newDogManager, _ in
            // end refresh first otherwise there will be a weird visual issue
            self.tableView.refreshControl?.endRefreshing()
            
            guard let newDogManager = newDogManager else {
                return
            }
            
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.refreshLogsTitle, forSubtitle: VisualConstant.BannerTextConstant.refreshLogsSubtitle, forStyle: .success)
            self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
        }
    }
    
    /// Updates dogManagerDependents then reloads table
    private func reloadTable() {
        // important to store this value so we don't recompute more than needed
        logsForDogIdsGroupedByDate = dogManager.logsForDogIdsGroupedByDate(forLogsFilter: logsFilter)
        tableView.isUserInteractionEnabled = logsForDogIdsGroupedByDate.isEmpty == false
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // additional section at the end for the loader section
        return logsForDogIdsGroupedByDate.count + (pageLoaderSectionIndex != nil ? 1 : 0)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if we want to display rows, there must be logs to display, and if there is logs to display then there must be a page loader section
        guard logsForDogIdsGroupedByDate.isEmpty == false, let pageLoaderSectionIndex = pageLoaderSectionIndex else {
            return 0
        }
        
        guard section != pageLoaderSectionIndex else {
            // There is either 0 or 1 rows in the page loader section.
            // If there is 1 row in the p.l.s., then the p.l.s. can load more rows when we scoll to it
            // If there is 0 rows in the p.l.s., then the p.l.s. cannot load more rows when we scroll to it
            
            // find the number of logs currently displayed
            let numberOfLogsDisplayed = {
                var count = 0
                logsForDogIdsGroupedByDate.forEach { dogIdLogPairs in
                    count += dogIdLogPairs.count
                }
                return count
            }()
            // if the number of the logs currently displayed is equal to the page limit, then that means there is likely more logs to show. Therefore, we display a row for the loader section so it can load more rows
            return numberOfLogsDisplayed == LogsTableViewController.logsDisplayedLimit ? 1 : 0
        }
        
        return logsForDogIdsGroupedByDate[section].count
       
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let pageLoaderSectionIndex = pageLoaderSectionIndex, section != pageLoaderSectionIndex else {
            // no header for a page loader section
            return nil
        }
        
        let headerView = LogsHeaderView()
        
        let date = logsForDogIdsGroupedByDate[section].first?.1.logDate ?? Date()
        headerView.setup(fromDate: date)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let pageLoaderSectionIndex = pageLoaderSectionIndex, section != pageLoaderSectionIndex else {
            // no header for a page loader section
            return 0.0
        }
        
        return LogsHeaderView.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var shouldShowFilterIndicator: Bool {
            if indexPath.section == 0 && logsFilter != [:] {
                return true
            }
            else {
                return false
            }
        }
        
        guard logsForDogIdsGroupedByDate.isEmpty == false, let pageLoaderSectionIndex = pageLoaderSectionIndex, indexPath.section != pageLoaderSectionIndex else {
            // there are either no rows to display, or the current section is the loader section which means we don't display any custom cells
            return UITableViewCell()
        }
        
        let (dogId, log) = logsForDogIdsGroupedByDate[indexPath.section][indexPath.row]
        
        guard let dog = dogManager.findDog(forDogId: dogId) else {
            return UITableViewCell()
        }
        
        let cell = dog.dogIcon != nil
        ? tableView.dequeueReusableCell(withIdentifier: "LogsBodyWithIconTableViewCell", for: indexPath)
        : tableView.dequeueReusableCell(withIdentifier: "LogsBodyWithoutIconTableViewCell", for: indexPath)
        
        if let dogIcon = dog.dogIcon, let castedCell = cell as? LogsBodyWithIconTableViewCell {
            castedCell.setup(forParentDogIcon: dogIcon, forLog: log)
            
            castedCell.containerView.roundCorners(setCorners: .none)
            
            // This cell is a top cell
            if indexPath.row == 0 {
                castedCell.containerView.roundCorners(addCorners: .top)
            }
            // This cell is a bottom cell (and possibly a top cell as well)
            if indexPath.row == logsForDogIdsGroupedByDate[indexPath.section].count - 1 {
                castedCell.containerView.roundCorners(addCorners: .bottom)
            }
        }
        else if let castedCell = cell as? LogsBodyWithoutIconTableViewCell {
            castedCell.setup(forParentDogName: dog.dogName, forLog: log)
            
            castedCell.containerView.roundCorners(setCorners: .none)
            
            // This cell is a top cell
            if indexPath.row == 0 {
                castedCell.containerView.roundCorners(addCorners: .top)
            }
            // This cell is a bottom cell (and possibly a top cell as well)
            if indexPath.row == logsForDogIdsGroupedByDate[indexPath.section].count - 1 {
                castedCell.containerView.roundCorners(addCorners: .bottom)
            }
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let pageLoaderSectionIndex = pageLoaderSectionIndex, indexPath.section != pageLoaderSectionIndex else {
            // can't edit a row in a page loader section
            return false
        }
        
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        guard let pageLoaderSectionIndex = pageLoaderSectionIndex, indexPath.section != pageLoaderSectionIndex else {
            // cant edit a row in a page loader section
            return
        }
        
        let (forDogId, forLog) = logsForDogIdsGroupedByDate[indexPath.section][indexPath.row]
        
        LogsRequest.delete(invokeErrorManager: true, forDogId: forDogId, forLogId: forLog.logId) { requestWasSuccessful, _ in
            guard requestWasSuccessful, let dog = self.dogManager.findDog(forDogId: forDogId) else {
                return
            }
            
            if let logToRemove = dog.dogLogs.logs.first(where: { logToRemove in
                return logToRemove.logId == forLog.logId
            }) {
                dog.dogLogs.removeLog(forLogId: logToRemove.logId)
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let pageLoaderSectionIndex = pageLoaderSectionIndex, indexPath.section != pageLoaderSectionIndex else {
            // can't select a row in a page loader section
            self.tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let (forDogId, forLog) = logsForDogIdsGroupedByDate[indexPath.section][indexPath.row]
        
        PresentationManager.beginFetchingInformationIndictator()
        LogsRequest.get(invokeErrorManager: true, forDogId: forDogId, forLog: forLog) { log, responseStatus in
            PresentationManager.endFetchingInformationIndictator {
                self.tableView.deselectRow(at: indexPath, animated: true)
                
                guard let log = log else {
                    if responseStatus == .successResponse {
                        // If the response was successful but no log was returned, that means the log was deleted. Therefore, update the dogManager to indicate as such.
                        self.dogManager.findDog(forDogId: forDogId)?.dogLogs.removeLog(forLogId: forLog.logId)
                        self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    }
                    return
                }
                
                self.delegate.didSelectLog(forDogId: forDogId, forLog: log)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // we are aiming to load more data if the user has scrolled to the bottom. this in indicated by the page loader section being shown
        guard let pageLoaderSectionIndex = pageLoaderSectionIndex, indexPath.section == pageLoaderSectionIndex else {
            return
        }
        
        LogsTableViewController.logsDisplayedLimit += 250
        reloadTable()
    }
    
}
