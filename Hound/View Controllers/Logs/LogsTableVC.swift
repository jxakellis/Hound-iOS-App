//
//  LogsTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsTableViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
    func didSelectLog(forDogId: Int, log: Log)
    func shouldToggleNoLogsRecorded(isHidden: Bool)
}

final class LogsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    /// Array of tuples [[(forDogId, log)]]. This array has all of the logs for all of the dogs grouped what unique day/month/year they occured on, first element is furthest in the future and last element is the oldest. Optionally filters by the dogId and logAction provides IMPORTANT to store this value so we don't recompute more than needed
    private var logsForDogIdsGroupedByDate: [[(Int, Log)]] = []
    
    private var storedLogsFilter: [Int: [LogAction]] = [:]
    // Dictionary Literal of Dog IDs and their corresponding log actions. This indicates which dog(s) to filter by and what log actions of theirs to also filter by. [:] indicates no filter and all items are shown
    var logsFilter: [Int: [LogAction]] {
        get {
            return storedLogsFilter
        }
        set (newLogsFilter) {
            self.storedLogsFilter = newLogsFilter
            
            // If the view isn't currently visible, then we don't reload the data. We only reload the data once necessary, otherwise it's unnecessary processing to reload data that isn't in use. Without this change, for example, we could reloadTable() multiple times while a user is just modify reminders on the reminders page.
            guard isViewLoaded && view.window != nil else {
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
    
    weak var delegate: LogsTableViewControllerDelegate! = nil
    
    // MARK: Page Loader
    
    /// Number of logs that can be simultaneously displayed
    static var logsDisplayedLimit: Int = 200
    
    /// The section in the table view designated for the page loader.
    var pageLoaderSection: Int? {
        guard logsForDogIdsGroupedByDate.isEmpty == false else {
            return nil
        }
        // logsForDogIdsGroupedByDate.count == 2
        // section 0: first for logsForDogIdsGroupedByDate
        // section 1: second for logsForDogIdsGroupedByDate
        // section 2: page loader
        return logsForDogIdsGroupedByDate.count
    }
    
    // MARK: - Dog Manager
    
    private(set) var dogManager: DogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        reloadTable()
        
        if (sender.localized is LogsTableViewController) == true {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        
        delegate.shouldToggleNoLogsRecorded(isHidden: !logsForDogIdsGroupedByDate.isEmpty)
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = true
        self.tableView.separatorInset = .zero
        // allow for refreshing of the information from the server
        self.tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if tableViewDataSourceHasBeenUpdated {
            tableViewDataSourceHasBeenUpdated = false
        }
        if storedLogsInterfaceScale != UserConfiguration.logsInterfaceScale {
            storedLogsInterfaceScale = UserConfiguration.logsInterfaceScale
        }
        
        reloadTable()
    }
    
    // MARK: - Functions
    
    /// Makes a query to the server to retrieve new information then refreshed the tableView
    @objc private func refreshTable() {
        DogsRequest.get(invokeErrorManager: true, dogManager: dogManager) { newDogManager, _ in
            // end refresh first otherwise there will be a weird visual issue
            self.tableView.refreshControl?.endRefreshing()
            
            guard let newDogManager = newDogManager else {
                return
            }
            
            AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.refreshLogsTitle, forSubtitle: VisualConstant.BannerTextConstant.refreshLogsSubtitle, forStyle: .success)
            self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
        }
    }
    
    /// Updates dogManagerDependents then reloads table
    private func reloadTable() {
        
        // important to store this value so we don't recompute more than needed
        logsForDogIdsGroupedByDate = dogManager.logsForDogIdsGroupedByDate(forLogsFilter: logsFilter)
        
        if logsForDogIdsGroupedByDate.isEmpty {
            tableView.separatorStyle = .none
        }
        else {
            tableView.separatorStyle = .singleLine
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // additional section at the end for the loader section
        return logsForDogIdsGroupedByDate.count + (pageLoaderSection != nil ? 1 : 0)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if we want to display rows, there must be logs to display, and if there is logs to display then there must be a page loader section
        guard logsForDogIdsGroupedByDate.isEmpty == false, let pageLoaderSection = pageLoaderSection else {
            return 0
        }
        
        guard section != pageLoaderSection else {
            // either one or zero rows in the page loader section
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
        // we know there is some data to be displayed now
        
        // find the number of logs for a given unique day/month/year, then add 1 for the header that says the day/month/year
        return logsForDogIdsGroupedByDate[section].count + 1
       
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
        
        guard logsForDogIdsGroupedByDate.isEmpty == false, let pageLoaderSection = pageLoaderSection, indexPath.section != pageLoaderSection else {
            // there are either no rows to display, or the current section is the loader section which means we don't display any custom cells
            return UITableViewCell()
        }
        
        guard indexPath.row > 0 else {
            // logs are present and need a header (row being zero indicates that the cell is a header)
            let nestedLogsArray: [(Int, Log)] = logsForDogIdsGroupedByDate[indexPath.section]
            
            // For the given parent array, we will take the first log in the nested array. The header will extract the date information from that log. It doesn't matter which log we take as all logs will have the same day, month, and year since they were already sorted to be in that array.
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogsHeaderTableViewCell", for: indexPath)
            
            if let customCell = cell as? LogsHeaderTableViewCell {
                customCell.setup(fromDate: nestedLogsArray[0].1.logDate, shouldShowFilterIndictator: shouldShowFilterIndicator)
            }
            
            return cell
        }
        
        // log
        let nestedLogsArray: [(Int, Log)] = logsForDogIdsGroupedByDate[indexPath.section]
        
        // indexPath.row -1 corrects for the first row in the section being the header
        let targetTuple = nestedLogsArray[indexPath.row - 1]
        
        guard let dog = dogManager.findDog(forDogId: targetTuple.0) else {
            return UITableViewCell()
        }
        let log = targetTuple.1
        
        // has dogIcon
        if let dogIcon = dog.dogIcon {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogsBodyWithIconTableViewCell", for: indexPath)
            
            if let customCell = cell as? LogsBodyWithIconTableViewCell {
                customCell.setup(forParentDogIcon: dogIcon, forLog: log)
            }
            
            return cell
        }
        // no dogIcon
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogsBodyWithoutIconTableViewCell", for: indexPath)
            
            if let customCell = cell as? LogsBodyWithoutIconTableViewCell {
                customCell.setup(forParentDogName: dog.dogName, forLog: log)
            }
            
            return cell
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let pageLoaderSection = pageLoaderSection, indexPath.section != pageLoaderSection else {
            // can't edit a row in a page loader section
            return false
        }
        
        // can rows that aren't header (header at .row == 0)
        return indexPath.row != 0
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        guard let pageLoaderSection = pageLoaderSection, indexPath.section != pageLoaderSection else {
            // cant edit a row in a page loader section
            return
        }
        
        // identify components needed to remove data
        
        // let originalNumberOfSections = logsForDogIdsGroupedByDate.count
        
        let nestedLogsArray = logsForDogIdsGroupedByDate[indexPath.section]
        let (forDogId, forLog) = nestedLogsArray[indexPath.row - 1]
        
        LogsRequest.delete(invokeErrorManager: true, forDogId: forDogId, forLogId: forLog.logId) { requestWasSuccessful, _ in
            guard requestWasSuccessful, let dog = self.dogManager.findDog(forDogId: forDogId) else {
                return
            }
            
            // Remove the row from the data source
            // find log in dog and remove
            for dogLogIndex in 0..<dog.dogLogs.logs.count where dog.dogLogs.logs[dogLogIndex].logId == forLog.logId {
                dog.dogLogs.removeLog(forIndex: dogLogIndex)
                break
            }
            
            self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let pageLoaderSection = pageLoaderSection, indexPath.section != pageLoaderSection else {
            // can't select a row in a page loader section
            self.tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let nestedLogsArray = logsForDogIdsGroupedByDate[indexPath.section]
        let (forDogId, forLog) = nestedLogsArray[indexPath.row - 1]
        
        RequestUtils.beginRequestIndictator()
        LogsRequest.get(invokeErrorManager: true, forDogId: forDogId, forLog: forLog) { log, responseStatus in
            RequestUtils.endRequestIndictator {
                self.tableView.deselectRow(at: indexPath, animated: true)
                
                guard let log = log else {
                    if responseStatus == .successResponse {
                        // If the response was successful but no log was returned, that means the log was deleted. Therefore, update the dogManager to indicate as such.
                        self.dogManager.findDog(forDogId: forDogId)?.dogLogs.removeLog(forLogId: forLog.logId)
                        self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    }
                    return
                }
                
                self.delegate.didSelectLog(forDogId: forDogId, log: log)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // we are aiming to load more data if the user has scrolled to the bottom. this in indicated by the page loader section being shown
        guard let pageLoaderSection = pageLoaderSection, indexPath.section == pageLoaderSection else {
            return
        }
        
        LogsTableViewController.logsDisplayedLimit += 200
        reloadTable()
    }
    
}
