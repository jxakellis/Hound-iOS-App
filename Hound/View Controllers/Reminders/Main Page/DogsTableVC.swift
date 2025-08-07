//
//  DogsTableVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsTableVCDelegate: AnyObject {
    func shouldOpenDogMenu(dogUUID: UUID?)
    func shouldOpenReminderMenu(dogUUID: UUID, reminder: Reminder?)
    func shouldOpenTriggerMenu(dog: Dog, trigger: Trigger?)
    func didUpdateDogManager(sender: Sender, dogManager: DogManager)
    func shouldUpdateAlphaForButtons(alpha: Double)
}

final class DogsTableVC: HoundTableViewController {
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let referenceContentOffsetY = referenceContentOffsetY else { return }
        
        // Sometimes the default contentOffset.y isn't 0.0, in testing it was -47.0, so we want to adjust that value to 0.0
        let adjustedContentOffsetY = scrollView.contentOffset.y - referenceContentOffsetY
        // When scrollView.contentOffset.y reaches the value of alphaConstant, the UI element's alpha is set to 0 and is hidden.
        let alphaConstant: Double = 100.0
        let alpha: Double = max(1.0 - (adjustedContentOffsetY / alphaConstant), 0.0)
        delegate?.shouldUpdateAlphaForButtons(alpha: alpha)
    }
    
    // MARK: - Properties
    
    private weak var delegate: DogsTableVCDelegate?
    
    private var loopTimer: Timer?
    
    // MARK: - Dog Manager
    
    private(set) var dogManager: DogManager = DogManager()
    
    func setDogManager(sender: Sender, dogManager: DogManager) {
        self.dogManager = dogManager
        
        // possible senders
        // DogsAddDogReminderTVC
        // DogTVC
        // DogsVC
        if !(sender.lastLocation is DogsVC) {
            delegate?.didUpdateDogManager(sender: Sender(source: sender, lastLocation: self), dogManager: dogManager)
        }
        if !(sender.lastLocation is DogsReminderTVC) && !(sender.source is DogsTableVC) {
            // source could be anything and could not be in view so no animation
            self.tableView.reloadData()
        }
        if sender.lastLocation is DogsReminderTVC {
            self.reloadVisibleCellsNextAlarmLabels()
        }
        
        // start up loop timer, normally done in view will appear but sometimes view has appeared and doesn't need a loop but then it can get a dogManager update which requires a loop. This happens due to reminder added in DogsIntroduction page.
        if viewIsBeingViewed == true && loopTimer == nil {
            loopTimer = Timer(fireAt: Date(), interval: 1.0, target: self, selector: #selector(self.reloadVisibleCellsNextAlarmLabels), userInfo: nil, repeats: true)
            
            if let loopTimer = loopTimer {
                RunLoop.main.add(loopTimer, forMode: .common)
            }
        }
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(DogTVC.self, forCellReuseIdentifier: DogTVC.reuseIdentifier)
        self.tableView.register(DogsReminderTVC.self, forCellReuseIdentifier: DogsReminderTVC.reuseIdentifier)
        self.tableView.contentInset.top = Constant.Constraint.Spacing.absoluteVertInset
        self.tableView.contentInset.bottom = Constant.Constraint.Spacing.absoluteVertInset
        self.tableView.allowsSelection = !dogManager.dogs.isEmpty
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refreshTableData), for: .valueChanged)
    }
    
    private var viewIsBeingViewed: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewIsBeingViewed = true
        
        // not in view so no animation
        self.tableView.reloadData()
        
        loopTimer = Timer(fireAt: Date(), interval: 1.0, target: self, selector: #selector(self.reloadVisibleCellsNextAlarmLabels), userInfo: nil, repeats: true)
        
        if let loopTimer = loopTimer {
            RunLoop.main.add(loopTimer, forMode: .common)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewIsBeingViewed = false
        
        loopTimer?.invalidate()
        loopTimer = nil
    }
    
    // MARK: - Setup
    
    func setup(delegate: DogsTableVCDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Functions
    
    @objc private func reloadVisibleCellsNextAlarmLabels() {
        guard tableView.visibleCells.isEmpty == false else {
            loopTimer?.invalidate()
            loopTimer = nil
            return
        }
        
        for cell in tableView.visibleCells {
            (cell as? DogsReminderTVC)?.reloadNextAlarmLabel()
        }
    }
    
    /// Makes a query to the server to retrieve new information then refreshed the tableView
    @objc private func refreshTableData() {
        PresentationManager.beginFetchingInformationIndicator()
        DogsRequest.get(errorAlert: .automaticallyAlertOnlyForFailure, dogManager: dogManager) { newDogManager, responseStatus, _ in
            PresentationManager.endFetchingInformationIndicator {
                // end refresh first otherwise there will be a weird visual issue
                self.tableView.refreshControl?.endRefreshing()
                
                guard responseStatus != .failureResponse, let newDogManager = newDogManager else {
                    return
                }
                
                if responseStatus == .successResponse {
                    PresentationManager.enqueueBanner(title: Constant.Visual.BannerText.successRefreshRemindersTitle, subtitle: Constant.Visual.BannerText.successRefreshRemindersSubtitle, style: .success)
                }
                else {
                    if OfflineModeManager.shared.hasDisplayedOfflineModeBanner == true {
                        // If OfflineModeManager has displayed its banner that indicates its turning on, then we are safe to display this banner. Otherwise, we would run the risk of both of these banners displaying if its the first time enterin offline mode.
                        PresentationManager.enqueueBanner(title: Constant.Visual.BannerText.infoRefreshOnHoldTitle, subtitle: Constant.Visual.BannerText.infoRefreshOnHoldSubtitle, style: .info)
                    }
                }
                
                self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: newDogManager)
                // manually reload table as the self sender doesn't do that
                // whole page is changing so no animation
                self.tableView.reloadData()
            }
        }
    }
    
    private func willShowDogActionSheet(cell: DogTVC, indexPath: IndexPath) {
        guard let dog = cell.dog, let dogName = cell.dog?.dogName, let dogUUID = cell.dog?.dogUUID, let section = self.dogManager.dogs.firstIndex(where: { dog in
            dog.dogUUID == dogUUID
        }) else { return }
        
        let alertController = UIAlertController(title: "You Selected: \(dogName)", message: nil, preferredStyle: .actionSheet)
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addReminderAlertAction = UIAlertAction(title: "Add Reminder", style: .default) { _ in
            self.delegate?.shouldOpenReminderMenu(dogUUID: dogUUID, reminder: nil)
        }
        let addTriggerAlertAction = UIAlertAction(title: "Add Automation", style: .default) { _ in
            self.delegate?.shouldOpenTriggerMenu(dog: dog, trigger: nil)
        }
        
        let editAlertAction = UIAlertAction(
            title: "Edit Dog",
            style: .default,
            handler: { (_: UIAlertAction!)  in
                self.delegate?.shouldOpenDogMenu(dogUUID: dogUUID)
            })
        
        let removeAlertAction = UIAlertAction(title: "Delete Dog", style: .destructive) { _ in
            
            // REMOVE CONFIRMATION
            let removeDogConfirmation = UIAlertController(title: "Are you sure you want to delete \(dogName)?", message: nil, preferredStyle: .alert)
            
            let confirmRemoveDogAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                DogsRequest.delete(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID) { responseStatus, _ in
                    guard responseStatus != .failureResponse else {
                        return
                    }
                    self.dogManager.removeDog(dogUUID: dogUUID)
                    self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                    self.tableView.deleteSections([section], with: .automatic)
                    
                }
            }
            
            let confirmCancelRemoveDogAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            removeDogConfirmation.addAction(confirmRemoveDogAlertAction)
            removeDogConfirmation.addAction(confirmCancelRemoveDogAlertAction)
            
            PresentationManager.enqueueAlert(removeDogConfirmation)
        }
        
        alertController.addAction(addReminderAlertAction)
        alertController.addAction(addTriggerAlertAction)
        
        alertController.addAction(editAlertAction)
        
        alertController.addAction(removeAlertAction)
        
        alertController.addAction(cancelAlertAction)
        
        PresentationManager.enqueueActionSheet(alertController, sourceView: cell)
    }
    
    /// Called when a reminder is tapped by the user, display an action sheet of possible modifcations to the alarm/reminder.
    private func willShowReminderActionSheet(cell: DogsReminderTVC, indexPath: IndexPath) {
        guard let dogUUID = cell.dogUUID, let dog = dogManager.findDog(dogUUID: dogUUID) else { return }
        
        guard let reminder = cell.reminder else { return }
        
        var alertControllerTitle = "You Selected: \(reminder.reminderActionType.convertToReadableName(customActionName: reminder.reminderCustomActionName)) for \(dog.dogName)"
        if reminder.reminderIsTriggerResult {
            alertControllerTitle += "\n\nReminders created by automations cannot be edited"
        }
        let selectedReminderAlertController = UIAlertController(title: alertControllerTitle, message: nil, preferredStyle: .actionSheet)
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let editAlertAction = UIAlertAction(title: "Edit Reminder", style: .default) { _ in
            self.delegate?.shouldOpenReminderMenu(dogUUID: dogUUID, reminder: reminder)
        }
        
        // REMOVE BUTTON
        let removeAlertAction = UIAlertAction(title: "Delete Reminder", style: .destructive) { _ in
            
            // REMOVE CONFIRMATION
            let removeReminderConfirmation = UIAlertController(title: "Are you sure you want to delete \(reminder.reminderActionType.convertToReadableName(customActionName: reminder.reminderCustomActionName))?", message: nil, preferredStyle: .alert)
            
            let removeReminderConfirmationRemove = UIAlertAction(title: "Delete", style: .destructive) { _ in
                RemindersRequest.delete(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dog.dogUUID, reminderUUIDs: [reminder.reminderUUID]) { responseStatus, _ in
                    guard responseStatus != .failureResponse else {
                        return
                    }
                    
                    let numReminders = self.dogManager.dogs[indexPath.section].dogReminders.dogReminders.count
                    if numReminders > 1 && indexPath.row == numReminders {
                        // there is a reminder above its its the new bottom, so it needs its corners rounded
                        let aboveReminderCell = self.tableView.cellForRow(at: IndexPath(row: indexPath.row - 1, section: indexPath.section)) as? DogsReminderTVC
                        UIView.animate(withDuration: Constant.Visual.Animation.showOrHideSingleElement) {
                            aboveReminderCell?.containerView.roundCorners(setCorners: .bottom)
                        }
                    }
                    dog.dogReminders.removeReminder(reminderUUID: reminder.reminderUUID)
                    self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                
            }
            
            let removeReminderConfirmationCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            removeReminderConfirmation.addAction(removeReminderConfirmationRemove)
            removeReminderConfirmation.addAction(removeReminderConfirmationCancel)
            
            PresentationManager.enqueueAlert(removeReminderConfirmation)
            
        }
        
        let skipOnceAlertAction = UIAlertAction(
            title: "Skip Once",
            style: .default,
            handler: { _ in
                self.userSkippedReminderOnce(dogUUID: dog.dogUUID, reminder: reminder)
                PresentationManager.enqueueBanner(title: "Skipped \(reminder.reminderActionType.convertToReadableName(customActionName: reminder.reminderCustomActionName)) Once", subtitle: nil, style: .success)
            })
        
        // DETERMINES IF ITS A LOG BUTTON OR UNDO LOG BUTTON
        let shouldUndoLogOrUnskip: Bool = {
            guard reminder.reminderIsEnabled == true && reminder.snoozeComponents.executionInterval == nil else {
                return false
            }
            
            return (reminder.reminderType == .weekly && reminder.weeklyComponents.isSkipping) || (reminder.reminderType == .monthly && reminder.monthlyComponents.isSkipping)
        }()
        
        let shouldShowSkipOnceAction: Bool = {
            guard shouldUndoLogOrUnskip == false else {
                return false
            }
            
            guard reminder.reminderIsEnabled == true && reminder.snoozeComponents.executionInterval == nil && reminder.reminderType != .oneTime else {
                return false
            }
            
            return true
        }()
        
        // STORES LOG BUTTON(S)
        var alertActionsForLog: [UIAlertAction] = []
        
        // ADD LOG BUTTONS (MULTIPLE IF POTTY OR OTHER SPECIAL CASE)
        if shouldUndoLogOrUnskip == true {
            let logToUndo = findLogFromSkippedReminder(dog: dog, reminder: reminder)
            
            let logAlertAction = UIAlertAction(
                title:
                    (logToUndo != nil
                     ? "Undo Log "
                     : "Undo Skip ")
                + "for \(reminder.reminderActionType.convertToReadableName(customActionName: reminder.reminderCustomActionName))",
                style: .default,
                handler: { (_: UIAlertAction!)  in
                    self.userSelectedUnskipReminder(dog: dog, reminder: reminder)
                    
                    let bannerTitle = (logToUndo != nil
                                       ? "Undid "
                                       : "Unskipped ")
                    + (reminder.reminderActionType.convertToReadableName(customActionName: reminder.reminderCustomActionName))
                    PresentationManager.enqueueBanner(title: bannerTitle, subtitle: nil, style: .success)
                    
                })
            alertActionsForLog.append(logAlertAction)
        }
        else {
            // Cant convert a reminderActionType of potty directly to logActionType, as it has serveral possible outcomes. Otherwise, logActionType and reminderActionType 1:1
            let logActionTypes: [LogActionType] = reminder.reminderActionType.associatedLogActionTypes
            
            for logActionType in logActionTypes {
                let fullReadableName = logActionType.convertToReadableName(customActionName: reminder.reminderCustomActionName, includeMatchingEmoji: true)
                let logAlertAction = UIAlertAction(
                    title: "Log \(fullReadableName)",
                    style: .default,
                    handler: { _ in
                        self.userPreemptivelyLoggedReminder(dogUUID: dog.dogUUID, reminder: reminder, logActionType: logActionType)
                        PresentationManager.enqueueBanner(title: "Logged \(fullReadableName)", subtitle: nil, style: .success)
                    })
                alertActionsForLog.append(logAlertAction)
            }
        }
        
        for logAlertAction in alertActionsForLog {
            selectedReminderAlertController.addAction(logAlertAction)
        }
        
        if shouldShowSkipOnceAction == true {
            selectedReminderAlertController.addAction(skipOnceAlertAction)
        }
        
        if reminder.reminderIsTriggerResult == false {
            selectedReminderAlertController.addAction(editAlertAction)
        }
        
        selectedReminderAlertController.addAction(removeAlertAction)
        
        selectedReminderAlertController.addAction(cancelAlertAction)
        
        PresentationManager.enqueueActionSheet(selectedReminderAlertController, sourceView: cell)
        
    }
    
    /// The user went to log/skip a reminder on the reminders page. Must updating skipping data and add a log.
    private func userPreemptivelyLoggedReminder(dogUUID: UUID, reminder: Reminder, logActionType: LogActionType) {
        let log = Log(logActionTypeId: logActionType.logActionTypeId, logCustomActionName: reminder.reminderCustomActionName, logStartDate: Date(), logCreatedByReminderUUID: nil)
        
        // special case. Once a oneTime reminder executes/ is skipped, it must be delete. Therefore there are special server queries.
        if reminder.reminderType == .oneTime {
            // make request to add log, then (if successful) make request to delete reminder
            
            // delete the reminder on the server
            RemindersRequest.delete(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, reminderUUIDs: [reminder.reminderUUID]) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    return
                }
                
                if let dogSection = self.dogManager.dogs.firstIndex(where: { $0.dogUUID == dogUUID }),
                   let reminderIndex = self.dogManager.dogs[dogSection].dogReminders.dogReminders.firstIndex(where: { $0.reminderUUID == reminder.reminderUUID }) {
                    let indexPath = IndexPath(row: reminderIndex + 1, section: dogSection)
                    
                    let numReminders = self.dogManager.dogs[indexPath.section].dogReminders.dogReminders.count
                    if numReminders > 1 && indexPath.row == numReminders {
                        // there is a reminder above its its the new bottom, so it needs its corners rounded
                        let aboveReminderCell = self.tableView.cellForRow(at: IndexPath(row: indexPath.row - 1, section: indexPath.section)) as? DogsReminderTVC
                        UIView.animate(withDuration: Constant.Visual.Animation.showOrHideSingleElement) {
                            aboveReminderCell?.containerView.roundCorners(setCorners: .bottom)
                        }
                    }
                    self.dogManager.dogs[dogSection].dogReminders.removeReminder(reminderUUID: reminder.reminderUUID)
                    self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                    
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    //                    UIView.animate(withDuration: Constant.Visual.Animation.moveMultipleElements) {
                    //                        self.view.setNeedsLayout()
                    //                        self.view.layoutIfNeeded()
                    //                    }
                }
                else {
                    self.dogManager.findDog(dogUUID: dogUUID)?.dogReminders.removeReminder(reminderUUID: reminder.reminderUUID)
                    self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                    self.tableView.reloadData()
                }
                
                LogsRequest.create(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, log: log) { responseStatusLogCreate, _ in
                    guard responseStatusLogCreate != .failureResponse else {
                        return
                    }
                    
                    let triggerReminders = self.dogManager.findDog(dogUUID: dogUUID)?.dogLogs.addLog(log: log, invokeDogTriggers: true)
                    self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                    
                    guard let triggerReminders = triggerReminders, !triggerReminders.isEmpty else {
                        return
                    }
                    
                    // silently try to create trigger reminders
                    RemindersRequest.create(errorAlert: .automaticallyAlertForNone, dogUUID: dogUUID, reminders: triggerReminders) { responseStatus, _ in
                        guard responseStatus != .failureResponse else {
                            return
                        }
                        self.dogManager.findDog(dogUUID: dogUUID)?.dogReminders.addReminders(reminders: triggerReminders)
                        self.delegate?.didUpdateDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                    }
                }
            }
        }
        // Nest all the other cases inside this else statement as otherwise .oneTime alarms would make request with the above code then again down here.
        else {
            reminder.enableIsSkipping(skippedDate: Date())
            
            // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
            RemindersRequest.update(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, reminders: [reminder]) { responseStatusReminderUpdate, _ in
                guard responseStatusReminderUpdate != .failureResponse else {
                    return
                }
                
                self.dogManager.findDog(dogUUID: dogUUID)?.dogReminders.addReminder(reminder: reminder)
                self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                
                LogsRequest.create(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, log: log) { responseStatusLogCreate, _ in
                    guard responseStatusLogCreate != .failureResponse else {
                        return
                    }
                    
                    let triggerReminders = self.dogManager.findDog(dogUUID: dogUUID)?.dogLogs.addLog(log: log, invokeDogTriggers: true)
                    self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                    
                    guard let triggerReminders = triggerReminders, !triggerReminders.isEmpty else {
                        return
                    }
                    
                    // silently try to create trigger reminders
                    RemindersRequest.create(errorAlert: .automaticallyAlertForNone, dogUUID: dogUUID, reminders: triggerReminders) { responseStatus, _ in
                        guard responseStatus != .failureResponse else {
                            return
                        }
                        self.dogManager.findDog(dogUUID: dogUUID)?.dogReminders.addReminders(reminders: triggerReminders)
                        self.delegate?.didUpdateDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                    }
                }
            }
        }
    }
    
    /// The user went to log/skip a reminder on the reminders page. Must updating skipping data and add a log.
    private func userSkippedReminderOnce(dogUUID: UUID, reminder: Reminder) {
        guard reminder.reminderType != .oneTime else { return }
        
        reminder.enableIsSkipping(skippedDate: Date())
        
        // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
        RemindersRequest.update(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, reminders: [reminder]) { responseStatusReminderUpdate, _ in
            guard responseStatusReminderUpdate != .failureResponse else {
                return
            }
            
            self.dogManager.findDog(dogUUID: dogUUID)?.dogReminders.addReminder(reminder: reminder)
            self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
        }
    }
    
    /// If a reminder was skipped, it could have either been a preemptive log (meaning there was a log created) or it was skipped without a log. Thus, locate the log if it exists.
    private func findLogFromSkippedReminder(dog: Dog, reminder: Reminder) -> Log? {
        // this is the time that the reminder's next alarm was skipped. at this same moment, a log was added. If this log is still there, with it's date unmodified by the user, then we remove it.
        let dateOfLogToRemove: Date? = {
            if reminder.reminderType == .weekly {
                return reminder.weeklyComponents.skippedDate
            }
            else if reminder.reminderType == .monthly {
                return reminder.monthlyComponents.skippedDate
            }
            
            return nil
        }()
        
        guard let dateOfLogToRemove = dateOfLogToRemove else {
            return nil
        }
        
        // find log that is incredibly close the time where the reminder was skipped, once found, then we delete it.
        let logToRemove = dog.dogLogs.dogLogs.first(where: { log in
            return abs(dateOfLogToRemove.distance(to: log.logStartDate)) < 0.001
        })
        
        return logToRemove
    }
    
    /// The user went to unlog/unskip a reminder on the reminders page. Must update skipping information. Note: only weekly/monthly reminders can be skipped therefore only they can be unskipped.
    private func userSelectedUnskipReminder(dog: Dog, reminder: Reminder) {
        // we can only unskip a weekly/monthly reminder that is currently isSkipping == true
        guard (reminder.reminderType == .weekly && reminder.weeklyComponents.isSkipping == true) || (reminder.reminderType == .monthly && reminder.monthlyComponents.isSkipping == true) else { return }
        
        reminder.disableIsSkipping()
        
        // make request to the server, if successful then we persist the data. If there is an error, then we discard to data to keep client and server in sync (as server wasn't able to update)
        RemindersRequest.update(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dog.dogUUID, reminders: [reminder]) { responseStatusReminderUpdate, _ in
            guard responseStatusReminderUpdate != .failureResponse else {
                return
            }
            
            self.dogManager.findDog(dogUUID: dog.dogUUID)?.dogReminders.addReminder(reminder: reminder)
            self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
            
            // find log that is incredibly close the time where the reminder was skipped, once found, then we delete it.
            guard let logToRemove = self.findLogFromSkippedReminder(dog: dog, reminder: reminder) else {
                return
            }
            
            // log to remove from unlog event. Attempt to delete the log server side
            LogsRequest.delete(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dog.dogUUID, logUUID: logToRemove.logUUID) { responseStatusLogDelete, _ in
                guard responseStatusLogDelete != .failureResponse else {
                    return
                }
                
                self.dogManager.findDog(dogUUID: dog.dogUUID)?.dogLogs.removeLog(logUUID: logToRemove.logUUID)
                self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
            }
            
        }
    }
    
    override func didUpdateUserTimeZone() {
        self.tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dogManager.dogs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard dogManager.dogs.isEmpty == false else {
            return 0
        }
        
        return dogManager.dogs[section].dogReminders.dogReminders.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constant.Constraint.Spacing.contentTallIntraVert
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let footer = HoundHeaderFooterView()
        return footer
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard dogManager.dogs.isEmpty == false else {
            return HoundTableViewCell()
        }
        
        let cell = indexPath.row == 0
        ? tableView.dequeueReusableCell(withIdentifier: DogTVC.reuseIdentifier, for: indexPath)
        : tableView.dequeueReusableCell(withIdentifier: DogsReminderTVC.reuseIdentifier, for: indexPath)
        
        if let castedCell = cell as? DogTVC {
            castedCell.setup(dog: dogManager.dogs[indexPath.section])
            castedCell.containerView.roundCorners(setCorners: .all)
            
            if dogManager.dogs[indexPath.section].dogReminders.dogReminders.isEmpty {
                // if there is a reminder cell below this cell, we want to the white background of the reminder cell to "continuously" flow from the reminder cell to under this cell. the only way we can make that happen, is having a white background layer below out blue table view cell (which appears if there is a cell below this)
                castedCell.containerExtraBackgroundView.isHidden = true
            }
            else {
                castedCell.containerExtraBackgroundView.isHidden = false
            }
        }
        else if let castedCell = cell as? DogsReminderTVC {
            castedCell.setup(dogUUID: dogManager.dogs[indexPath.section].dogUUID, reminder: dogManager.dogs[indexPath.section].dogReminders.dogReminders[indexPath.row - 1])
            
            // This cell is a bottom cell
            if indexPath.row == dogManager.dogs[indexPath.section].dogReminders.dogReminders.count {
                castedCell.containerView.roundCorners(setCorners: .bottom)
            }
            else {
                castedCell.containerView.roundCorners(setCorners: .none)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard dogManager.dogs.isEmpty == false else { return }
        
        if indexPath.row == 0, let dogsDogDisplayTableViewCell = tableView.cellForRow(at: indexPath) as? DogTVC {
            willShowDogActionSheet(cell: dogsDogDisplayTableViewCell, indexPath: indexPath)
        }
        else if indexPath.row > 0, let dogsReminderDisplayTableViewCell = tableView.cellForRow(at: indexPath) as? DogsReminderTVC {
            willShowReminderActionSheet(cell: dogsReminderDisplayTableViewCell, indexPath: indexPath)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete && dogManager.dogs.isEmpty == false else { return }
        var removeConfirmation: UIAlertController?
        
        // delete dog
        if indexPath.row == 0, let dogCell = tableView.cellForRow(at: indexPath) as?  DogTVC, let dog = dogCell.dog {
            // cell in question
            
            removeConfirmation = UIAlertController(title: "Are you sure you want to delete \(dog.dogName)?", message: nil, preferredStyle: .alert)
            
            let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                DogsRequest.delete(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dog.dogUUID) { responseStatus, _ in
                    guard responseStatus != .failureResponse else {
                        return
                    }
                    
                    self.dogManager.removeDog(dogUUID: dog.dogUUID)
                    self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                    self.tableView.deleteSections([indexPath.section], with: .automatic)
                    UIView.animate(withDuration: Constant.Visual.Animation.moveMultipleElements) {
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                    }
                    
                }
                
            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            removeConfirmation?.addAction(removeAlertAction)
            removeConfirmation?.addAction(cancelAlertAction)
        }
        // delete reminder
        if indexPath.row > 0, let reminderCell = tableView.cellForRow(at: indexPath) as? DogsReminderTVC, let dogUUID = reminderCell.dogUUID, let dog: Dog = dogManager.findDog(dogUUID: dogUUID), let reminder = reminderCell.reminder {
            removeConfirmation = UIAlertController(title: "Are you sure you want to delete \(reminder.reminderActionType.convertToReadableName(customActionName: reminder.reminderCustomActionName))?", message: nil, preferredStyle: .alert)
            
            let removeAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                RemindersRequest.delete(errorAlert: .automaticallyAlertOnlyForFailure, dogUUID: dogUUID, reminderUUIDs: [reminder.reminderUUID]) { responseStatus, _ in
                    guard responseStatus != .failureResponse else {
                        return
                    }
                    
                    let numReminders = self.dogManager.dogs[indexPath.section].dogReminders.dogReminders.count
                    if numReminders > 1 && indexPath.row == numReminders {
                        // there is a reminder above its its the new bottom, so it needs its corners rounded
                        let aboveReminderCell = tableView.cellForRow(at: IndexPath(row: indexPath.row - 1, section: indexPath.section)) as? DogsReminderTVC
                        UIView.animate(withDuration: Constant.Visual.Animation.showOrHideSingleElement) {
                            aboveReminderCell?.containerView.roundCorners(setCorners: .bottom)
                        }
                    }
                    dog.dogReminders.removeReminder(reminderUUID: reminder.reminderUUID)
                    self.setDogManager(sender: Sender(source: self, lastLocation: self), dogManager: self.dogManager)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                
            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            removeConfirmation?.addAction(removeAlertAction)
            removeConfirmation?.addAction(cancelAlertAction)
        }
        
        if let removeConfirmation = removeConfirmation {
            PresentationManager.enqueueAlert(removeConfirmation)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        dogManager.dogs.count >= 1
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
