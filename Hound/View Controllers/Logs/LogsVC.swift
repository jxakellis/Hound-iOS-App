//
//  LogsViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager)
}

final class LogsViewController: UIViewController, UIGestureRecognizerDelegate, LogsTableViewControllerDelegate, DropDownUIViewDataSource, LogsAddLogViewControllerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - LogsAddLogViewControllerDelegate & LogsTableViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)
        
        if sender.origin is LogsAddLogViewController {
            CheckManager.checkForReview()
            CheckManager.checkForShareHound()
        }
    }
    
    // MARK: - LogsTableViewControllerDelegate
    
    func didUpdateAlphaForButtons(forAlpha: Double) {
        addLogButton.alpha = forAlpha
        exportLogsButton.alpha = forAlpha
        filterLogsButton.alpha = forAlpha
        
        addLogButton.isHidden = (forAlpha == 0) || dogManager.dogs.isEmpty
        exportLogsButton.isHidden = (forAlpha == 0) || !familyHasAtLeastOneLog
        // filterLogsButton.isHidden = (forAlpha == 0) || !familyHasAtLeastOneLog
    }
    
    func didSelectLog(forDogId: Int, forLog: Log) {
        logsAddLogViewControllerDogIdToUpdate = forDogId
        logsAddLogViewControllerLogToUpdate = forLog
        self.performSegueOnceInWindowHierarchy(segueIdentifier: "LogsAddLogViewController")
    }
    
    func shouldUpdateNoLogsRecorded(forIsHidden: Bool) {
        noLogsRecordedLabel?.isHidden = forIsHidden
        if dogManager.dogs.isEmpty {
            noLogsRecordedLabel?.text = "No logs recorded! Try creating a dog and adding some logs to it..."
        }
        else if dogManager.dogs.count == 1, let dog = dogManager.dogs.first {
            noLogsRecordedLabel?.text = "No logs recorded! Try adding some to \(dog.dogName)..."
        }
        else if dogManager.dogs.count >= 1 {
            noLogsRecordedLabel?.text = "No logs recorded! Try adding some to one of your dogs..."
        }
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var noLogsRecordedLabel: GeneralUILabel!
    
    @IBOutlet private weak var addLogButton: GeneralWithBackgroundUIButton!
    
    @IBOutlet private weak var filterLogsButton: GeneralWithBackgroundUIButton!
    @IBAction private func didTouchUpInsideFilterLogs(_ sender: Any) {
        // TODO NOW revamp filter UI. Make it like the luluemon (or any online store)'s filter system. Allow user to pick dog(s) to filter by, then allow user to pick logs to filter by, and also allow the user to pick users to filter by. By default none of the options are selected which means all of them are included in the result. E.g. user can open the log filter menu, under dogs they can select ginger and penny, under log types they can select Potty: Pee, and under users they can select Michael.
        let numberOfRowsToDisplay: Int = {
            
            // finds the total count of rows needed
            let totalNumberOfRowsNeeded: Int = {
                var count = 0
                for dog in dogManager.dogs {
                    // need a row for each dog
                    count += 1
                    // need a row for each unique log action of each dog
                    count += dog.dogLogs.uniqueLogActions.count
                }
                
                // need a row for "clear filter"
                return count + 1
            }()
            
            // finds the total number of rows that can be displayed and makes sure that the needed does not exceed that
            let maximumHeight = self.view.safeAreaLayoutGuide.layoutFrame.size.height
            let neededHeight = DropDownUIView.rowHeightForLogFilter * CGFloat(totalNumberOfRowsNeeded)
            
            if neededHeight < maximumHeight {
                return totalNumberOfRowsNeeded
            }
            else {
                return Int((maximumHeight / DropDownUIView.rowHeightForLogFilter).rounded(.down))
            }
        }()
        
        dropDown.showDropDown(numberOfRowsToShow: CGFloat(numberOfRowsToDisplay), animated: true)
    }
    
    @IBOutlet private weak var exportLogsButton: GeneralWithBackgroundUIButton!
    @IBAction private func didTouchUpInsideExportLogs(_ sender: Any) {
        guard let logsTableViewController = logsTableViewController else {
            ErrorConstant.ExportError.exportLogs().alert()
            return
        }
        
        var dogIdLogTuples: [(Int, Log)] = []
        
        // logsForDogIdsGroupedByDate is a 2D array, where each parent array is a given day of year and each child array is the chronologically sorted logs for that day
        logsTableViewController.logsForDogIdsGroupedByDate.forEach { arrayOfDogIdLogTuples in
            dogIdLogTuples += arrayOfDogIdLogTuples
        }
        
        ExportManager.exportLogs(forDogIdLogTuples: dogIdLogTuples)
    }
    
    // MARK: - Properties
    
    private let dropDown = DropDownUIView()
    
    // Dictionary literal the currently applied logsFilter. [ "currentDogId" : ["filterByAction1","filterByAction2"]]. Filters by selected actions under selected dogs. Note: if the dictionary literal is empty, then shows all
    private var logsFilter: [Int: [LogAction]] = [:]
    
    private var familyHasAtLeastOneLog: Bool {
        return dogManager.dogs.contains { dog in
            return dog.dogLogs.logs.isEmpty == false
        }
    }
    
    private(set) var logsTableViewController: LogsTableViewController?
    
    private var logsAddLogViewControllerDogIdToUpdate: Int?
    private var logsAddLogViewControllerLogToUpdate: Log?
    private(set) var logsAddLogViewController: LogsAddLogViewController?
    
    weak var delegate: LogsViewControllerDelegate!
    
    // MARK: - Dog Manager
    
    private(set) var dogManager: DogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
        
        // verify logs filter is valid, something could have been deleted
        for (dogId, logActions) in logsFilter {
            guard let dog = dogManager.findDog(forDogId: dogId) else {
                // there is no corresponding dog in the dogManager for the dogId in the logs filter, remove that dog from the logs filter
                logsFilter.removeValue(forKey: dogId)
                continue
            }
            
            for logAction in logActions where dog.dogLogs.uniqueLogActions.contains(logAction) == false {
                // there is no corresponding log action in the dog for the log action in the logs filter, remove that log action from the logs filter
                logsFilter[dogId]?.removeAll(where: { $0 == logAction })
                
                if logsFilter[dogId]?.isEmpty == true {
                    // if we removed the last log action for a given dogId, then also remove that dogId
                    logsFilter.removeValue(forKey: dogId)
                }
            }
        }
        
        addLogButton?.isHidden = dogManager.dogs.isEmpty
        exportLogsButton?.isHidden = !familyHasAtLeastOneLog
        // filterLogsButton?.isHidden = !familyHasAtLeastOneLog
        
        if (sender.localized is LogsTableViewController) == false {
            logsTableViewController?.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        if (sender.localized is MainTabBarController) == true {
            if logsAddLogViewController?.viewIfLoaded?.window == nil {
                // If logsAddLogViewController isn't being actively viewed, we dismiss it when the dog manager updates. This is because a dog could have been added or removed, however if a user is actively viewing the page, this interruption would cause too much inconvience for the slight edge case where a dog was modified.
                logsAddLogViewController?.dismiss(animated: true)
            }
        }
        // we dont want to update MainTabBarController with the delegate if its the one providing the update
        if (sender.localized is MainTabBarController) == false {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
                    
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideDropDown))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.cancelsTouchesInView = false
        containerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /// Certain views must be adapted in viewDidLayoutSubviews as properties (such as frames) are not updated until the subviews are laid out (before that point in time they hold the placeholder storyboard value). However, viewDidLayoutSubviews is called multiple times, therefore we must lock it to executing certain code once with this variable. viewDidLayoutSubviews is the superior choice to viewDidAppear as viewDidAppear has the downside of performing these changes once the user can see the view
    private var didSetupCustomSubviews: Bool = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // LogsViewController IS NOT EMBEDDED inside other view controllers. This means IT HAS safe area insets. Only the view controllers that are presented onto MainTabBarController or are in the navigation stack have safe area insets. This is because those views take up the whole screen, so they MUST consider the phone's safe area (i.e. top bar with time, wifi, and battery and bottom bar).
        
        guard didSetupSafeArea() == true && didSetupCustomSubviews == false else {
            return
        }
        
        didSetupCustomSubviews = true
        
        /// Finds the widthNeeded by the largest label, has a minimum and maximum possible along with subtracting the space taken by leading and trailing constraints.
        var neededWidthForLabel: CGFloat {
            let maximumWidth: CGFloat = view.safeAreaLayoutGuide.layoutFrame.width - 24.0
            let minimumWidth: CGFloat = 100.0 - 24.0
            
            /// Finds the largestWidth taken up by any label, later compared to constraint sizes of min and max. Leading and trailing constraints not considered here, that will be adjusted later
            var largestLabelWidth: CGFloat {
                
                var largest: CGFloat = "Clear Filter".bounding(font: VisualConstant.FontConstant.semiboldFilterByDogLabel, height: DropDownUIView.rowHeightForLogFilter).width
                
                for dog in dogManager.dogs {
                    let dogNameWidth = dog.dogName.bounding(font: VisualConstant.FontConstant.semiboldFilterByDogLabel, height: DropDownUIView.rowHeightForLogFilter).width
                    
                    if dogNameWidth > largest {
                        largest = dogNameWidth
                    }
                    
                    for uniqueLogAction in dog.dogLogs.uniqueLogActions {
                        let logActionWidth = uniqueLogAction.rawValue.bounding(font: VisualConstant.FontConstant.regularFilterByLogLabel, height: DropDownUIView.rowHeightForLogFilter).width
                        
                        if logActionWidth > largest {
                            largest = logActionWidth
                        }
                        
                    }
                }
                
                return largest
            }
            
            switch largestLabelWidth {
            case 0..<minimumWidth:
                return minimumWidth
            case minimumWidth...maximumWidth:
                return largestLabelWidth.rounded(.up)
            default:
                return maximumWidth
            }
        }
        
        /// only one dropdown used on the dropdown instance so no identifier needed
        dropDown.dropDownUIViewIdentifier = ""
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.dataSource = self
        dropDown.setupDropDown(viewPositionReference: (CGRect(origin: self.view.safeAreaLayoutGuide.layoutFrame.origin, size: CGSize(width: neededWidthForLabel + (DropDownUIView.insetForLogFilter * 2), height: 0.0))), offset: 0.0)
        dropDown.nib = UINib(nibName: "DropDownLogFilterTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: DropDownUIView.rowHeightForLogFilter)
        self.view.addSubview(dropDown)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dropDown.hideDropDown(removeFromSuperview: true)
    }
    
    // MARK: - Functions
    
    @objc private func hideDropDown() {
        dropDown.hideDropDown()
    }
    
    // MARK: - Drop Down Data Source
    
    func setupCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        
        guard let customCell = cell as? DropDownLogFilterTableViewCell else {
            return
        }
        
        // clear filter
        if indexPath.section == dogManager.dogs.count {
            customCell.setup(forDog: nil, forLogAction: nil)
        }
        else {
            let dog = dogManager.dogs[indexPath.section]
            // dog name header
            if indexPath.row == 0 {
                customCell.setup(forDog: dog, forLogAction: nil)
            }
            // dog log filter
            else {
                customCell.setup(forDog: dog, forLogAction: dog.dogLogs.uniqueLogActions[indexPath.row - 1])
            }
        }
        
        // check to see if the cell is a "Clear Filter" cell, if it is, then set it to not selected and return
        guard customCell.dogId != nil else {
            customCell.setCustomSelectedTableViewCell(forSelected: false)
            return
        }
        
        for dogId in logsFilter.keys where dogId == customCell.dogId {
            // the cell has a dogId and no logAction so is displaying a dogName. Its dogId is in the logsFilter dictionary, we can select the cell as that dog is selected
            if customCell.logAction == nil {
                customCell.setCustomSelectedTableViewCell(forSelected: true)
                return
            }
            
            // the cell has a logAction, check to see if that logAction is in the filter dictionary. if it is, then we select the cell and return
            if let logActions = logsFilter[dogId] {
                for logAction in logActions where logAction == customCell.logAction {
                    // the cell has a dogId and a logAction that match the filter dictionary, therefore we can select the cell
                    customCell.setCustomSelectedTableViewCell(forSelected: true)
                    return
                }
            }
        }
        
        // the cell didn't match any conditions above, so set it as not selected
        customCell.setCustomSelectedTableViewCell(forSelected: false)
    }
    
    func numberOfRows(forSection section: Int, dropDownUIViewIdentifier: String) -> Int {
        
        guard dogManager.dogs.isEmpty == false else {
            return 1
        }
        // We are on the last section. This one is reserved for "Clear Filter"
        if section == dogManager.dogs.count {
            return 1
        }
        // Regular section, corresponds to a dog
        else {
            // A row for the dogName and rows for all of the logActions
            return dogManager.dogs[section].dogLogs.uniqueLogActions.count + 1
        }
        
    }
    
    func numberOfSections(dropDownUIViewIdentifier: String) -> Int {
        // We add an extra section for the "Clear Filter" text at the end
        return dogManager.dogs.count + 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, dropDownUIViewIdentifier: String) {
        guard let dropDownTableView = dropDown.dropDownTableView, let selectedCell = dropDownTableView.cellForRow(at: indexPath) as? DropDownLogFilterTableViewCell else {
            return
        }
        // flip isCustomSelected status
        selectedCell.setCustomSelectedTableViewCell(forSelected: !selectedCell.isCustomSelected)
        
        // dog log filter was selected
        if let dogId = selectedCell.dogId, let logAction = selectedCell.logAction {
            // find any preexisting logActions that we are filtering by
            var existingLogActionFilters: [LogAction] = logsFilter[dogId] ?? []
            
            // the cell is now selected, add logAction to logsFilter array
            if selectedCell.isCustomSelected {
                // add additional logAction to filter by
                existingLogActionFilters.append(logAction)
                // assign array to dogId
                logsFilter[dogId] = existingLogActionFilters
                
                // Check to see if we just added the first logAction filter for a certain dog
                if existingLogActionFilters.count == 1 {
                    // this is the first logAction selected under the dog. Therefore, the dog cell won't be selected. Therefore, we have to select the dog cell
                    if let dogCell = dropDown.dropDownTableView?.cellForRow(at: IndexPath(row: 0, section: indexPath.section)) as? DropDownLogFilterTableViewCell {
                        dogCell.setCustomSelectedTableViewCell(forSelected: true)
                    }
                }
            }
            // cell is now unselected, remove logAction from logsFilter array
            else {
                // find index of logAction to remove from logsFilter array
                let indexToRemove = existingLogActionFilters.firstIndex(of: logAction)
                
                guard let indexToRemove = indexToRemove else {
                    return
                }
                // remove logAction from logsFilter array
                existingLogActionFilters.remove(at: indexToRemove)
                // assign array to dogId
                logsFilter[dogId] = existingLogActionFilters
                
                // check to see if we removed the the last logAction.
                if existingLogActionFilters.isEmpty {
                    // We removed the last logAction for a dog. Remove the logsFilter key and unselect the dog
                    logsFilter[dogId] = nil
                    if let dogCell = dropDown.dropDownTableView?.cellForRow(at: IndexPath(row: 0, section: indexPath.section)) as? DropDownLogFilterTableViewCell {
                        dogCell.setCustomSelectedTableViewCell(forSelected: false)
                    }
                }
            }
        }
        // dog fitler was selected
        else if let dogId = selectedCell.dogId {
            
            guard let dog = dogManager.findDog(forDogId: dogId) else {
                return
            }
            
            // the dog filter is now selected, make sure every logAction under it is also selected and added to the filter array
            if selectedCell.isCustomSelected {
                // make array of logActions to filter by
                // assign array to dogId, so logsFilter array is updated
                logsFilter[dogId] = dog.dogLogs.uniqueLogActions
                
                // now select all the logAction cells (we have 1 dogCell and x logAction rows, so subtract 1 to correct the count)
                let numberOfLogActionRows = numberOfRows(forSection: indexPath.section, dropDownUIViewIdentifier: "") - 1
                for logActionRow in 0..<numberOfLogActionRows {
                    // shift logActionRow by 1, as first row cell is a dogCell so we select the proper cell
                    if let logActionCell = dropDown.dropDownTableView?.cellForRow(at: IndexPath(row: logActionRow + 1, section: indexPath.section)) as? DropDownLogFilterTableViewCell {
                        logActionCell.setCustomSelectedTableViewCell(forSelected: true)
                    }
                }
            }
            // the dog filter is now unselected, make sure every logAction under it is also unselcted
            else {
                // clear logsFilter array
                logsFilter[dogId] = nil
                
                // deselect all the logAction cells (we have 1 dogCell and x logAction rows, so subtract 1 to correct the count)
                let numberOfLogActionRows = numberOfRows(forSection: indexPath.section, dropDownUIViewIdentifier: "") - 1
                for logActionRow in 0..<numberOfLogActionRows {
                    // shift logActionRow by 1, as first row cell is a dogCell so we select the proper cell
                    if let logActionCell = dropDown.dropDownTableView?.cellForRow(at: IndexPath(row: logActionRow + 1, section: indexPath.section)) as? DropDownLogFilterTableViewCell {
                        logActionCell.setCustomSelectedTableViewCell(forSelected: false)
                    }
                }
            }
        }
        // "Clear Filter" row was selected
        else {
            logsFilter = [:]
            
            // deselect all the dog and logAction cells
            let numberOfDogSections = numberOfSections(dropDownUIViewIdentifier: "") - 1
            // go through all of the dog sections
            for dogSection in 0..<numberOfDogSections {
                let numberOfRows = numberOfRows(forSection: dogSection, dropDownUIViewIdentifier: "")
                
                // for each dog section, go through both the dog and logAction cells
                for cellRow in 0..<numberOfRows {
                    if let cell = dropDown.dropDownTableView?.cellForRow(at: IndexPath(row: cellRow, section: dogSection)) as? DropDownLogFilterTableViewCell {
                        cell.setCustomSelectedTableViewCell(forSelected: false)
                    }
                }
            }
            
            dropDown.hideDropDown()
        }
        
        // logsFilter is configured, now apply it to the table view controller
        logsTableViewController?.logsFilter = logsFilter
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let logsTableViewController = segue.destination as? LogsTableViewController {
            self.logsTableViewController = logsTableViewController
            logsTableViewController.delegate = self
            
            logsTableViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        }
        else if let logsAddLogViewController = segue.destination as? LogsAddLogViewController {
            self.logsAddLogViewController = logsAddLogViewController
            logsAddLogViewController.setup(forDelegate: self, forDogManager: self.dogManager, forDogIdToUpdate: logsAddLogViewControllerDogIdToUpdate, forLogToUpdate: logsAddLogViewControllerLogToUpdate)
            logsAddLogViewControllerDogIdToUpdate = nil
            logsAddLogViewControllerLogToUpdate = nil
        }
    }
    
}
